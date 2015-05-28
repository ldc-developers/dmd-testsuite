import core.stdc.errno;
import core.sys.linux.epoll;

enum PollerEventType : int { a }

struct PollerEvent {
    PollerEventType type;
    int fd;
}

struct Epoll {
    ushort[1024] regFds;
    int epollFd = -1;
    epoll_event[32] events;
    PollerEvent[events.length * 4] pollerEvents;
}

struct Reactor {
    bool a = true;
    bool b;
    Epoll poll;
}

__gshared Reactor f;

Reactor* foo() {
    return &f;
}

void main() {}
