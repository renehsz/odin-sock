package sock

foreign import libc "system:c"
import "core:c"

// Communication Domain/Address Family
AddrFamily :: enum c.int {
	UNSPEC    = 0,
	UNIX      = 1, // Local communication
	INET      = 2, // IPv4 Internet protocols
	AX25      = 3, // Amateur radio AX.25 protocol
	IPX       = 4, // IPX - Novell protocols
	APPLETALK = 5, // AppleTalk
	NETROM    = 6, // Amateur radio NetROM
	BRIDGE    = 7, // Multiprotocol bridge
	AAL5      = 8, // Reserved for Werner's ATM
	X25       = 9, // ITU-T X.25 / ISO-8208 protocol
	INET6     = 10,// IPv6 Internet protocols
	RESERVED,
	MAX       = 12,
}

Type :: enum c.int {
	STREAM    = 1,  // stream (connection) socket
	DGRAM     = 2,  // datagram (conn.less) socket
	RAW       = 3,  // raw socket
	RDM       = 4,  // reliably-delivered message
	SEQPACKET = 5,  // sequential packet socket
	PACKET    = 10, /* linux specific way of
	                 * getting packets at the device
	                 * level.  For writing rarp and
	                 * other similar things at the
	                 * user level. Obsolete.       */
}

Addr :: struct {
	family: c.ushort, // address family, xxx
	data:   [14]byte, // 14 bytes of protocol address
}

InAddr :: struct {
	addr: c.ulong,
}

Addrin :: struct {
	family: c.short,
	port:   c.ushort,
	addr:   InAddr,
	zero:   [8]byte,
}

Linger :: struct {
	onoff:  c.int, // Linger active
	linger: c.int, // How long to linger for
}

Msghdr :: struct {
	name:       rawptr,  // Socket name
	namelen:    c.int,   // Length of name
	iov:        rawptr,  // Data blocks
	iovlen:     c.int,   // Number of blocks
	control:    rawptr,  // Per protocol magic (eg BSD file descriptor passing)
	controllen: c.int,   // Length of rights list
	flags:      c.int,   // 4.4 BSD item we dont use
}

Addrinfo :: struct {
	flags:     c.int,
	family:    AddrFamily,
	socktype:  Type,
	protocol:  c.int,
	addrlen:   c.uint,
	addr:      ^Addr,
	canonname: ^byte,
	next:      ^Addrinfo,
}

Hostent :: struct {
	name:      ^byte,  // The official name of the host
	aliases:   ^^byte, // An array of alternative names for the host, terminated by a null pointer
	addrtype:  c.int,  // The type of address; always AF_INET or AF_INET6 at present.
	length:    c.int,  // The length of the address in bytes.
	addr_list: ^^byte, // An array of pointers to network addresses for the host (in network byte order), terminated by a null pointer.
}

Protoent :: struct {
	name:    ^byte,  // official protocol name
	aliases: ^^byte, // alias list
	proto:   c.int,  // protocol #
}

Serevent :: struct {
	name:    ^byte,  // official service name
	aliases: ^^byte, // alias list
	port:    c.int,  // port #
	proto:   ^byte,  // protocol to use
}

Netent :: struct {
	name:     ^byte,
	aliases:  ^^byte,
	addrtype: c.int,
	net:      c.ulong,
}

Rpcent :: struct {
	name:    ^byte,
	aliases: ^^byte,
	proto:   c.int,
}

SOMAXCONN :: 128;

@(default_calling_convention="c")
foreign libc {
	h_errno: c.int;

	socket        :: proc(domain: AddrFamily, typ: Type, protocol: c.int) -> c.int ---;
	accept        :: proc(sockfd: c.int, addr: ^Addr, addrlen: c.uint) -> c.int ---;
	accept4       :: proc(sockfd: c.int, addr: ^Addr, addrlen: c.uint, flags: c.int) -> c.int ---;
	bind          :: proc(sockfd: c.int, addr: ^Addrin, addrlen: c.uint) -> c.int ---;
	connect       :: proc(sockfd: c.int, addr: ^Addr, addrlen: c.uint) -> c.int ---;
	getsockname   :: proc(sockfd: c.int, addr: ^Addr, addrlen: c.uint) -> c.int ---;
	listen        :: proc(sockfd, backlog: c.int) -> c.int ---;
	getifaddrs    :: proc(ifap: ^rawptr) -> c.int ---;
	freeifaddrs   :: proc(ifa: rawptr) ---;
	getaddrinfo   :: proc(node, service: ^byte, hints: ^Addrinfo, res: ^^Addrinfo) -> c.int ---;
	freeaddrinfo  :: proc(res: ^Addrinfo) ---;
	gai_strerror  :: proc(res: ^Addrinfo) -> ^byte ---;
	gethostbyname :: proc(name: ^byte) -> ^Hostent ---;
	gethostbyaddr :: proc(addr: rawptr, len: c.uint, typ: c.int) -> ^Hostent ---;
	sethostent    :: proc(stayopen: c.int) ---;
	endhostent    :: proc() ---;
	herror        :: proc(s: ^byte) ---;
	hstrerror     :: proc(err: c.int) -> ^byte ---;
	gethostent    :: proc() -> ^Hostent ---;

	htonl         :: proc(hostlong: u32) -> u32 ---;
	htons         :: proc(hostshort: u16) -> u16 ---;
	ntohl         :: proc(netlong: u32) -> u32 ---;
	ntohs         :: proc(netshort: u16) -> u16 ---;
}



// Error codes
HOST_NOT_FOUND ::  1;     // Authoritive Answer Host not found
TRY_AGAIN      ::  2;     // Non-Authoritive Host not found, or SERVERFAIL
NO_RECOVERY    ::  3;     // Non recoverable errors, FORMERR, REFUSED, NOTIMP
NO_DATA        ::  4;     // Valid name, no data record of requested type
NO_ADDRESS     ::  NO_DATA; // no address, look for MX record

EPERM          ::  1;      // Operation not permitted
ENOENT         ::  2;      // No such file or directory
ESRCH          ::  3;      // No such process
EINTR          ::  4;      // Interrupted system call
EIO            ::  5;      // I/O error
ENXIO          ::  6;      // No such device or address
E2BIG          ::  7;      // Arg list too long
ENOEXEC        ::  8;      // Exec format error
EBADF          ::  9;      // Bad file number
ECHILD         :: 10;      // No child processes
EAGAIN         :: 11;      // Try again
ENOMEM         :: 12;      // Out of memory
EACCES         :: 13;      // Permission denied
EFAULT         :: 14;      // Bad address
ENOTBLK        :: 15;      // Block device required
EBUSY          :: 16;      // Device or resource busy
EEXIST         :: 17;      // File exists
EXDEV          :: 18;      // Cross-device link
ENODEV         :: 19;      // No such device
ENOTDIR        :: 20;      // Not a directory
EISDIR         :: 21;      // Is a directory
EINVAL         :: 22;      // Invalid argument
ENFILE         :: 23;      // File table overflow
EMFILE         :: 24;      // Too many open files
ENOTTY         :: 25;      // Not a typewriter
ETXTBSY        :: 26;      // Text file busy
EFBIG          :: 27;      // File too large
ENOSPC         :: 28;      // No space left on device
ESPIPE         :: 29;      // Illegal seek
EROFS          :: 30;      // Read-only file system
EMLINK         :: 31;      // Too many links
EPIPE          :: 32;      // Broken pipe
EDOM           :: 33;      // Math argument out of domain of func
ERANGE         :: 34;      // Math result not representable
EDEADLK        :: 35;      // Resource deadlock would occur
ENAMETOOLONG   :: 36;      // File name too long
ENOLCK         :: 37;      // No record locks available
ENOSYS         :: 38;      // Function not implemented
ENOTEMPTY      :: 39;      // Directory not empty
ELOOP          :: 40;      // Too many symbolic links encountered
EWOULDBLOCK    :: EAGAIN;  // Operation would block
ENOMSG         :: 42;      // No message of desired type
EIDRM          :: 43;      // Identifier removed
ECHRNG         :: 44;      // Channel number out of range
EL2NSYNC       :: 45;      // Level 2 not synchronized
EL3HLT         :: 46;      // Level 3 halted
EL3RST         :: 47;      // Level 3 reset
ELNRNG         :: 48;      // Link number out of range
EUNATCH        :: 49;      // Protocol driver not attached
ENOCSI         :: 50;      // No CSI structure available
EL2HLT         :: 51;      // Level 2 halted
EBADE          :: 52;      // Invalid exchange
EBADR          :: 53;      // Invalid request descriptor
EXFULL         :: 54;      // Exchange full
ENOANO         :: 55;      // No anode
EBADRQC        :: 56;      // Invalid request code
EBADSLT        :: 57;      // Invalid slot

EDEADLOCK      :: EDEADLK;

EBFONT         :: 59;      // Bad font file format
ENOSTR         :: 60;      // Device not a stream
ENODATA        :: 61;      // No data available
ETIME          :: 62;      // Timer expired
ENOSR          :: 63;      // Out of streams resources
ENONET         :: 64;      // Machine is not on the network
ENOPKG         :: 65;      // Package not installed
EREMOTE        :: 66;      // Object is remote
ENOLINK        :: 67;      // Link has been severed
EADV           :: 68;      // Advertise error
ESRMNT         :: 69;      // Srmount error
ECOMM          :: 70;      // Communication error on send
EPROTO         :: 71;      // Protocol error
EMULTIHOP      :: 72;      // Multihop attempted
EDOTDOT        :: 73;      // RFS specific error
EBADMSG        :: 74;      // Not a data message
EOVERFLOW      :: 75;      // Value too large for defined data type
ENOTUNIQ       :: 76;      // Name not unique on network
EBADFD         :: 77;      // File descriptor in bad state
EREMCHG        :: 78;      // Remote address changed
ELIBACC        :: 79;      // Can not access a needed shared library
ELIBBAD        :: 80;      // Accessing a corrupted shared library
ELIBSCN        :: 81;      // .lib section in a.out corrupted
ELIBMAX        :: 82;      // Attempting to link in too many shared libraries
ELIBEXEC       :: 83;      // Cannot exec a shared library directly
EILSEQ         :: 84;      // Illegal byte sequence
ERESTART       :: 85;      // Interrupted system call should be restarted
ESTRPIPE       :: 86;      // Streams pipe error
EUSERS         :: 87;      // Too many users
ENOTSOCK       :: 88;      // Socket operation on non-socket
EDESTADDRREQ   :: 89;      // Destination address required
EMSGSIZE       :: 90;      // Message too long
EPROTOTYPE     :: 91;      // Protocol wrong type for socket
ENOPROTOOPT    :: 92;      // Protocol not available
EPROTONOSUPPORT:: 93;      // Protocol not supported
ESOCKTNOSUPPORT:: 94;      // Socket type not supported
EOPNOTSUPP     :: 95;      // Operation not supported on transport endpoint
EPFNOSUPPORT   :: 96;      // Protocol family not supported
EAFNOSUPPORT   :: 97;      // Address family not supported by protocol
EADDRINUSE     :: 98;      // Address already in use
EADDRNOTAVAIL  :: 99;      // Cannot assign requested address
ENETDOWN       :: 100;     // Network is down
ENETUNREACH    :: 101;     // Network is unreachable
ENETRESET      :: 102;     // Network dropped connection because of reset
ECONNABORTED   :: 103;     // Software caused connection abort
ECONNRESET     :: 104;     // Connection reset by peer
ENOBUFS        :: 105;     // No buffer space available
EISCONN        :: 106;     // Transport endpoint is already connected
ENOTCONN       :: 107;     // Transport endpoint is not connected
ESHUTDOWN      :: 108;     // Cannot send after transport endpoint shutdown
ETOOMANYREFS   :: 109;     // Too many references: cannot splice
ETIMEDOUT      :: 110;     // Connection timed out
ECONNREFUSED   :: 111;     // Connection refused
EHOSTDOWN      :: 112;     // Host is down
EHOSTUNREACH   :: 113;     // No route to host
EALREADY       :: 114;     // Operation already in progress
EINPROGRESS    :: 115;     // Operation now in progress
ESTALE         :: 116;     // Stale NFS file handle
EUCLEAN        :: 117;     // Structure needs cleaning
ENOTNAM        :: 118;     // Not a XENIX named type file
ENAVAIL        :: 119;     // No XENIX semaphores available
EISNAM         :: 120;     // Is a named type file
EREMOTEIO      :: 121;     // Remote I/O error
EDQUOT         :: 122;     // Quota exceeded

ENOMEDIUM      :: 123;     // No medium found
EMEDIUMTYPE    :: 124;     // Wrong medium type

