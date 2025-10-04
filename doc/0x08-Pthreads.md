# Operating Systems Cheat Sheet

## 📌 Process States and Life Cycle

Processes transition between different states during execution:

- **NEW** – Process is being created
- **READY** – Process is waiting to be assigned to CPU
- **RUNNING** – Instructions are being executed
- **WAITING/BLOCKED** – Process is waiting for some event (I/O, signal)
- **TERMINATED** – Process has finished execution

## 🔧 Process Creation and Management

### The `fork()` System Call

Creates a new process by duplicating the calling process.

```c
#include <unistd.h>
#include <sys/wait.h>

pid_t pid = fork();

if (pid == 0) {
    // Child process
    printf("I'm the child, PID: %d\n", getpid());
} else if (pid > 0) {
    // Parent process
    printf("I'm the parent, child PID: %d\n", pid);
    wait(NULL);  // Wait for child to finish
} else {
    // Fork failed
    perror("fork failed");
}
```

### The `exec()` Family

Replaces current process image with a new program:

| Function | Description |
|----------|-------------|
| `execl()` | Takes argument list |
| `execlp()` | Searches PATH |
| `execle()` | Takes environment |
| `execv()` | Takes argument vector |
| `execvp()` | Vector + PATH search |
| `execve()` | Vector + environment |

```c
// Example: execl()
execl("/bin/ls", "ls", "-l", NULL);

// Example: execvp() 
char *args[] = {"gcc", "program.c", "-o", "program", NULL};
execvp("gcc", args);
```

### Process Termination: `exit()` and `wait()`

```c
// Child process termination
exit(0);  // Normal termination
exit(1);  // Error termination

// Parent waiting for child
int status;
pid_t child_pid = wait(&status);

if (WIFEXITED(status)) {
    printf("Child exited with status: %d\n", WEXITSTATUS(status));
}

// Wait for specific child
waitpid(child_pid, &status, 0);

// Non-blocking wait
waitpid(-1, &status, WNOHANG);
```

### Complete Fork-Exec-Wait Example

```c
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>

int main() {
    pid_t pid = fork();
    
    if (pid == 0) {
        // Child: execute new program
        execl("/bin/echo", "echo", "Hello from child!", NULL);
        perror("exec failed");  // Only reached if exec fails
        exit(1);
    } else if (pid > 0) {
        // Parent: wait for child
        int status;
        wait(&status);
        printf("Child finished with status: %d\n", WEXITSTATUS(status));
    } else {
        perror("fork failed");
        return 1;
    }
    
    return 0;
}
```

## 🔔 Signals

Signals are software interrupts that notify processes of events.

### Common Signals

| Signal | Number | Default Action | Description |
|--------|--------|----------------|-------------|
| SIGHUP | 1 | Terminate | Hangup detected |
| SIGINT | 2 | Terminate | Interrupt (Ctrl+C) |
| SIGQUIT | 3 | Core dump | Quit (Ctrl+\) |
| SIGKILL | 9 | Terminate | Kill (cannot be caught) |
| SIGSEGV | 11 | Core dump | Segmentation fault |
| SIGTERM | 15 | Terminate | Termination request |
| SIGSTOP | 19 | Stop | Stop process |
| SIGCONT | 18 | Continue | Continue process |
| SIGCHLD | 17 | Ignore | Child status changed |

### Signal Handling

```c
#include <signal.h>

// Signal handler function
void signal_handler(int sig) {
    printf("Received signal %d\n", sig);
    if (sig == SIGINT) {
        printf("Caught Ctrl+C, exiting gracefully...\n");
        exit(0);
    }
}

int main() {
    // Register signal handler
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    
    // Advanced signal handling with sigaction
    struct sigaction sa;
    sa.sa_handler = signal_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(SIGINT, &sa, NULL);
    
    while (1) {
        printf("Running... Press Ctrl+C to exit\n");
        sleep(1);
    }
    
    return 0;
}
```

### Sending Signals

```c
#include <signal.h>

// Send signal to process
kill(pid, SIGTERM);        // Send SIGTERM to process
kill(pid, SIGKILL);        // Force kill process
kill(-1, SIGUSR1);         // Send to all processes (broadcast)
kill(0, SIGUSR1);          // Send to process group

// Send signal to self
raise(SIGABRT);

// Example: Parent-Child communication
if (fork() == 0) {
    // Child
    sleep(5);
    kill(getppid(), SIGUSR1);  // Send signal to parent
    exit(0);
} else {
    // Parent
    signal(SIGUSR1, signal_handler);
    pause();  // Wait for signal
}
```

## 🧵 Threads - Pthreads (POSIX Threads)

### Basic Thread Operations

```c
#include <pthread.h>
#include <stdio.h>

void* thread_function(void* arg) {
    int* data = (int*)arg;
    printf("Thread running with data: %d\n", *data);
    
    // Thread-specific work
    for (int i = 0; i < 5; i++) {
        printf("Thread %d: iteration %d\n", *data, i);
        sleep(1);
    }
    
    // Return value
    int* result = malloc(sizeof(int));
    *result = *data * 2;
    pthread_exit(result);
}

int main() {
    pthread_t threads[3];
    int thread_data[3] = {1, 2, 3};
    
    // Create threads
    for (int i = 0; i < 3; i++) {
        if (pthread_create(&threads[i], NULL, thread_function, &thread_data[i]) != 0) {
            perror("pthread_create failed");
            exit(1);
        }
    }
    
    // Wait for threads to complete
    for (int i = 0; i < 3; i++) {
        int* result;
        pthread_join(threads[i], (void**)&result);
        printf("Thread %d returned: %d\n", i, *result);
        free(result);
    }
    
    return 0;
}
```

### Thread Attributes

```c
pthread_attr_t attr;
pthread_attr_init(&attr);

// Set detached state
pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);

// Set stack size
size_t stacksize = 1024 * 1024;  // 1MB
pthread_attr_setstacksize(&attr, stacksize);

// Set scheduling policy
pthread_attr_setschedpolicy(&attr, SCHED_FIFO);

pthread_create(&thread, &attr, thread_function, NULL);
pthread_attr_destroy(&attr);
```

### Detached Threads

```c
// Create detached thread (no need to join)
pthread_t thread;
pthread_attr_t attr;
pthread_attr_init(&attr);
pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
pthread_create(&thread, &attr, thread_function, NULL);
pthread_attr_destroy(&attr);

// Or detach after creation
pthread_detach(thread);
```

## 🔄 Thread Pools and Implicit Threading

### Basic Thread Pool Implementation

```c
#include <pthread.h>
#include <stdlib.h>

typedef struct {
    void (*function)(void*);
    void* arg;
} task_t;

typedef struct {
    pthread_t* threads;
    task_t* queue;
    pthread_mutex_t queue_mutex;
    pthread_cond_t queue_cond;
    int queue_size;
    int queue_count;
    int queue_front;
    int queue_rear;
    int shutdown;
    int thread_count;
} threadpool_t;

void* worker_thread(void* arg) {
    threadpool_t* pool = (threadpool_t*)arg;
    
    while (1) {
        pthread_mutex_lock(&pool->queue_mutex);
        
        // Wait for work or shutdown
        while (pool->queue_count == 0 && !pool->shutdown) {
            pthread_cond_wait(&pool->queue_cond, &pool->queue_mutex);
        }
        
        if (pool->shutdown) {
            pthread_mutex_unlock(&pool->queue_mutex);
            pthread_exit(NULL);
        }
        
        // Get task from queue
        task_t task = pool->queue[pool->queue_front];
        pool->queue_front = (pool->queue_front + 1) % pool->queue_size;
        pool->queue_count--;
        
        pthread_mutex_unlock(&pool->queue_mutex);
        
        // Execute task
        task.function(task.arg);
    }
}

threadpool_t* threadpool_create(int thread_count, int queue_size) {
    threadpool_t* pool = malloc(sizeof(threadpool_t));
    
    pool->threads = malloc(sizeof(pthread_t) * thread_count);
    pool->queue = malloc(sizeof(task_t) * queue_size);
    pool->thread_count = thread_count;
    pool->queue_size = queue_size;
    pool->queue_count = 0;
    pool->queue_front = 0;
    pool->queue_rear = 0;
    pool->shutdown = 0;
    
    pthread_mutex_init(&pool->queue_mutex, NULL);
    pthread_cond_init(&pool->queue_cond, NULL);
    
    // Create worker threads
    for (int i = 0; i < thread_count; i++) {
        pthread_create(&pool->threads[i], NULL, worker_thread, pool);
    }
    
    return pool;
}

int threadpool_add_task(threadpool_t* pool, void (*function)(void*), void* arg) {
    pthread_mutex_lock(&pool->queue_mutex);
    
    if (pool->queue_count == pool->queue_size) {
        pthread_mutex_unlock(&pool->queue_mutex);
        return -1;  // Queue full
    }
    
    pool->queue[pool->queue_rear].function = function;
    pool->queue[pool->queue_rear].arg = arg;
    pool->queue_rear = (pool->queue_rear + 1) % pool->queue_size;
    pool->queue_count++;
    
    pthread_cond_signal(&pool->queue_cond);
    pthread_mutex_unlock(&pool->queue_mutex);
    
    return 0;
}
```

### OpenMP (Implicit Threading)

```c
#include <omp.h>

int main() {
    // Parallel for loop
    #pragma omp parallel for
    for (int i = 0; i < 100; i++) {
        printf("Thread %d processing %d\n", omp_get_thread_num(), i);
    }
    
    // Parallel sections
    #pragma omp parallel sections
    {
        #pragma omp section
        {
            printf("Section 1 executed by thread %d\n", omp_get_thread_num());
        }
        #pragma omp section
        {
            printf("Section 2 executed by thread %d\n", omp_get_thread_num());
        }
    }
    
    // Critical section
    int shared_var = 0;
    #pragma omp parallel for
    for (int i = 0; i < 1000; i++) {
        #pragma omp critical
        {
            shared_var++;
        }
    }
    
    // Reduction
    int sum = 0;
    #pragma omp parallel for reduction(+:sum)
    for (int i = 1; i <= 100; i++) {
        sum += i;
    }
    
    return 0;
}
```

Compile with: `gcc -fopenmp program.c -o program`

### Linux Clone System Call

```c
#define _GNU_SOURCE
#include <sched.h>
#include <sys/wait.h>

int thread_func(void* arg) {
    printf("New thread/process created\n");
    return 0;
}

int main() {
    void* stack = malloc(8192);
    void* stack_top = stack + 8192;
    
    // Create new thread (shares memory)
    pid_t pid = clone(thread_func, stack_top, 
                      CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND, NULL);
    
    if (pid == -1) {
        perror("clone failed");
        return 1;
    }
    
    waitpid(pid, NULL, 0);
    free(stack);
    
    return 0;
}
```

## 🔒 Process Synchronization - Theory

### Critical Section Problem

A critical section is a segment of code that accesses shared resources and must not be executed by more than one process/thread simultaneously.

**Requirements for Critical Section Solution:**
1. **Mutual Exclusion** - Only one process in critical section at a time
2. **Progress** - Selection of next process cannot be postponed indefinitely  
3. **Bounded Waiting** - Bound on number of times other processes can enter CS

### Test-and-Set (TAS)

```c
// Hardware atomic instruction
bool test_and_set(bool* target) {
    bool old_value = *target;
    *target = true;
    return old_value;
}

// Usage for mutual exclusion
bool lock = false;

void critical_section() {
    while (test_and_set(&lock))
        ; // Busy wait (spin lock)
        
    // Critical section
    
    lock = false; // Release lock
}
```

### Compare-and-Swap (CAS)

```c
// Hardware atomic instruction
int compare_and_swap(int* value, int expected, int new_value) {
    int old_value = *value;
    if (*value == expected)
        *value = new_value;
    return old_value;
}

// Usage for lock-free programming
int shared_counter = 0;

void increment() {
    int old_val, new_val;
    do {
        old_val = shared_counter;
        new_val = old_val + 1;
    } while (compare_and_swap(&shared_counter, old_val, new_val) != old_val);
}
```

## 🔐 Linux Atomic Operations

```c
#include <linux/atomic.h>

// Atomic integer type
atomic_t counter = ATOMIC_INIT(0);

// Atomic operations
atomic_inc(&counter);           // counter++
atomic_dec(&counter);           // counter--
atomic_add(5, &counter);        // counter += 5
atomic_sub(3, &counter);        // counter -= 3

// Atomic read/write
int value = atomic_read(&counter);
atomic_set(&counter, 10);

// Atomic compare and exchange
int old_val = atomic_cmpxchg(&counter, 5, 10);  // if counter == 5, set to 10

// Memory barriers
smp_mb();           // Full memory barrier
smp_rmb();          // Read memory barrier  
smp_wmb();          // Write memory barrier
```

### Preemption Control

```c
// Disable preemption
preempt_disable();
    // Critical section - cannot be preempted
preempt_enable();

// Check if preemption is disabled
if (preempt_count() > 0) {
    printf("Preemption is disabled\n");
}

// Enable/disable interrupts
local_irq_disable();
    // Critical section with interrupts disabled
local_irq_enable();

// Save and restore interrupt state
unsigned long flags;
local_irq_save(flags);
    // Critical section
local_irq_restore(flags);
```

## 🔓 Mutex Locks

### POSIX Mutex (Pthreads)

```c
#include <pthread.h>

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
int shared_resource = 0;

void* worker_thread(void* arg) {
    for (int i = 0; i < 1000; i++) {
        pthread_mutex_lock(&mutex);
        shared_resource++;  // Critical section
        pthread_mutex_unlock(&mutex);
    }
    return NULL;
}

int main() {
    pthread_t threads[5];
    
    // Create threads
    for (int i = 0; i < 5; i++) {
        pthread_create(&threads[i], NULL, worker_thread, NULL);
    }
    
    // Wait for threads
    for (int i = 0; i < 5; i++) {
        pthread_join(threads[i], NULL);
    }
    
    printf("Final value: %d\n", shared_resource);
    pthread_mutex_destroy(&mutex);
    return 0;
}
```

### Mutex Attributes and Types

```c
pthread_mutex_t mutex;
pthread_mutexattr_t attr;

pthread_mutexattr_init(&attr);

// Mutex types
pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);     // Basic mutex
pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);  // Recursive mutex
pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_ERRORCHECK); // Error checking

// Process sharing
pthread_mutexattr_setpshared(&attr, PTHREAD_PROCESS_SHARED);

pthread_mutex_init(&mutex, &attr);
pthread_mutexattr_destroy(&attr);
```

### Timed Mutex Operations

```c
#include <time.h>

struct timespec timeout;
clock_gettime(CLOCK_REALTIME, &timeout);
timeout.tv_sec += 5;  // 5 seconds timeout

int result = pthread_mutex_timedlock(&mutex, &timeout);
if (result == ETIMEDOUT) {
    printf("Mutex lock timed out\n");
} else if (result == 0) {
    // Got the lock
    pthread_mutex_unlock(&mutex);
}

// Try lock (non-blocking)
if (pthread_mutex_trylock(&mutex) == 0) {
    // Got the lock immediately
    pthread_mutex_unlock(&mutex);
} else {
    printf("Mutex is busy\n");
}
```

## 🚦 Semaphores

### POSIX Semaphores

```c
#include <semaphore.h>

// Named semaphore (inter-process)
sem_t* sem = sem_open("/my_semaphore", O_CREAT, 0644, 1);
if (sem == SEM_FAILED) {
    perror("sem_open failed");
    exit(1);
}

// Wait (P operation)
sem_wait(sem);
    // Critical section
sem_post(sem);  // Signal (V operation)

// Cleanup
sem_close(sem);
sem_unlink("/my_semaphore");
```

```c
// Unnamed semaphore (threads only)
sem_t sem;
sem_init(&sem, 0, 1);  // pshared=0 (threads), initial value=1

// Non-blocking wait
if (sem_trywait(&sem) == 0) {
    // Got the semaphore
    sem_post(&sem);
} else {
    printf("Semaphore not available\n");
}

// Timed wait
struct timespec timeout;
clock_gettime(CLOCK_REALTIME, &timeout);
timeout.tv_sec += 2;

if (sem_timedwait(&sem, &timeout) == 0) {
    // Got the semaphore
    sem_post(&sem);
}

sem_destroy(&sem);
```

### Producer-Consumer with Semaphores

```c
#define BUFFER_SIZE 10

sem_t empty, full, mutex;
int buffer[BUFFER_SIZE];
int in = 0, out = 0;

void producer() {
    int item;
    while (1) {
        item = produce_item();
        
        sem_wait(&empty);   // Wait for empty slot
        sem_wait(&mutex);   // Critical section
        
        buffer[in] = item;
        in = (in + 1) % BUFFER_SIZE;
        
        sem_post(&mutex);   // Exit critical section
        sem_post(&full);    // Signal full slot
    }
}

void consumer() {
    int item;
    while (1) {
        sem_wait(&full);    // Wait for full slot
        sem_wait(&mutex);   // Critical section
        
        item = buffer[out];
        out = (out + 1) % BUFFER_SIZE;
        
        sem_post(&mutex);   // Exit critical section
        sem_post(&empty);   // Signal empty slot
        
        consume_item(item);
    }
}

int main() {
    sem_init(&empty, 0, BUFFER_SIZE);  // Initially all empty
    sem_init(&full, 0, 0);             // Initially none full
    sem_init(&mutex, 0, 1);            // Binary semaphore
    
    pthread_t prod_thread, cons_thread;
    pthread_create(&prod_thread, NULL, producer, NULL);
    pthread_create(&cons_thread, NULL, consumer, NULL);
    
    pthread_join(prod_thread, NULL);
    pthread_join(cons_thread, NULL);
    
    return 0;
}
```

## 🖥️ Monitors (Concept)

Monitors are high-level synchronization constructs that provide mutual exclusion and condition synchronization.

### Monitor Structure (Conceptual)

```c
// Monitor for bounded buffer
monitor BoundedBuffer {
    int buffer[N];
    int count = 0, in = 0, out = 0;
    
    condition not_full, not_empty;
    
    void produce(int item) {
        while (count == N)
            wait(not_full);
            
        buffer[in] = item;
        in = (in + 1) % N;
        count++;
        
        signal(not_empty);
    }
    
    int consume() {
        while (count == 0)
            wait(not_empty);
            
        int item = buffer[out];
        out = (out + 1) % N;
        count--;
        
        signal(not_full);
        return item;
    }
}
```

### Implementing Monitor with Pthread Conditions

```c
typedef struct {
    int buffer[BUFFER_SIZE];
    int count, in, out;
    pthread_mutex_t mutex;
    pthread_cond_t not_full, not_empty;
} monitor_t;

void monitor_init(monitor_t* m) {
    m->count = m->in = m->out = 0;
    pthread_mutex_init(&m->mutex, NULL);
    pthread_cond_init(&m->not_full, NULL);
    pthread_cond_init(&m->not_empty, NULL);
}

void monitor_produce(monitor_t* m, int item) {
    pthread_mutex_lock(&m->mutex);
    
    while (m->count == BUFFER_SIZE) {
        pthread_cond_wait(&m->not_full, &m->mutex);
    }
    
    m->buffer[m->in] = item;
    m->in = (m->in + 1) % BUFFER_SIZE;
    m->count++;
    
    pthread_cond_signal(&m->not_empty);
    pthread_mutex_unlock(&m->mutex);
}

int monitor_consume(monitor_t* m) {
    pthread_mutex_lock(&m->mutex);
    
    while (m->count == 0) {
        pthread_cond_wait(&m->not_empty, &m->mutex);
    }
    
    int item = m->buffer[m->out];
    m->out = (m->out + 1) % BUFFER_SIZE;
    m->count--;
    
    pthread_cond_signal(&m->not_full);
    pthread_mutex_unlock(&m->mutex);
    
    return item;
}
```

## 🔄 Condition Variables

```c
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
int ready = 0;

void* waiter(void* arg) {
    pthread_mutex_lock(&mutex);
    
    while (!ready) {
        printf("Waiting for condition...\n");
        pthread_cond_wait(&cond, &mutex);  // Releases mutex while waiting
    }
    
    printf("Condition met!\n");
    pthread_mutex_unlock(&mutex);
    return NULL;
}

void* signaler(void* arg) {
    sleep(2);  // Simulate work
    
    pthread_mutex_lock(&mutex);
    ready = 1;
    pthread_cond_signal(&cond);  // Wake up one waiter
    // pthread_cond_broadcast(&cond);  // Wake up all waiters
    pthread_mutex_unlock(&mutex);
    
    return NULL;
}
```

### Read-Write Locks

```c
pthread_rwlock_t rwlock = PTHREAD_RWLOCK_INITIALIZER;
int shared_data = 0;

void* reader(void* arg) {
    pthread_rwlock_rdlock(&rwlock);
    printf("Reader: data = %d\n", shared_data);
    sleep(1);  // Simulate reading
    pthread_rwlock_unlock(&rwlock);
    return NULL;
}

void* writer(void* arg) {
    pthread_rwlock_wrlock(&rwlock);
    shared_data++;
    printf("Writer: updated data to %d\n", shared_data);
    sleep(1);  // Simulate writing
    pthread_rwlock_unlock(&rwlock);
    return NULL;
}
```

## 🛠️ Compilation and Usage

### Compiling Programs

```bash
# Basic compilation
gcc program.c -o program

# With pthread library
gcc program.c -lpthread -o program

# With OpenMP
gcc -fopenmp program.c -o program

# With debug symbols
gcc -g program.c -lpthread -o program

# With warnings
gcc -Wall -Wextra program.c -lpthread -o program
```

### Debugging Tools

```bash
# GDB for debugging
gdb ./program

# Valgrind for memory errors
valgrind --tool=memcheck ./program

# Helgrind for thread errors
valgrind --tool=helgrind ./program

# DRD for race condition detection  
valgrind --tool=drd ./program

# Strace for system call tracing
strace ./program
```

## 📊 Performance Monitoring

```c
#include <sys/time.h>
#include <time.h>

// Measure execution time
struct timespec start, end;
clock_gettime(CLOCK_MONOTONIC, &start);

// ... code to measure ...

clock_gettime(CLOCK_MONOTONIC, &end);
double time_taken = (end.tv_sec - start.tv_sec) + 
                   (end.tv_nsec - start.tv_nsec) / 1e9;
printf("Time taken: %f seconds\n", time_taken);
```

## 🚨 Common Pitfalls and Best Practices

### Avoiding Deadlocks

```c
// BAD: Different lock order can cause deadlock
// Thread 1:
pthread_mutex_lock(&mutex1);
pthread_mutex_lock(&mutex2);
// ...
pthread_mutex_unlock(&mutex2);
pthread_mutex_unlock(&mutex1);

// Thread 2:
pthread_mutex_lock(&mutex2);  // Different order!
pthread_mutex_lock(&mutex1);
// ...

// GOOD: Always acquire locks in same order
void transfer_money(account_t* from, account_t* to, int amount) {
    // Always lock lower address first
    pthread_mutex_t* first = (&from->mutex < &to->mutex) ? &from->mutex : &to->mutex;
    pthread_mutex_t* second = (&from->mutex < &to->mutex) ? &to->mutex : &from->mutex;
    
    pthread_mutex_lock(first);
    pthread_mutex_lock(second);
    
    from->balance -= amount;
    to->balance += amount;
    
    pthread_mutex_unlock(second);
    pthread_mutex_unlock(first);
}
```

### Memory Management in Threads

```c
// Thread-safe memory allocation
void* thread_func(void* arg) {
    // Local allocation is thread-safe
    char* local_buffer = malloc(1024);
    
    // Use thread_local for per-thread data
    static __thread int thread_counter = 0;
    thread_counter++;
    
    // Always free resources
    free(local_buffer);
    return NULL;
}
```

### Proper Error Handling

```c
int result = pthread_mutex_lock(&mutex);
if (result != 0) {
    fprintf(stderr, "Mutex lock failed: %s\n", strerror(result));
    return -1;
}

// Always unlock in error cases too
if (some_error_condition) {
    pthread_mutex_unlock(&mutex);
    return -1;
}

pthread_mutex_unlock(&mutex);
```