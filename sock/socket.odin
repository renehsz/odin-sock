package sock

foreign import libc "system:c"
import "core:c"
import "core:os"

/* NOTE(renehsz):
 *  I'm still unsure about whether I should use primitive types or define my
 *  own destinct ones. E.g.: socklen_t, ...
 *  Also I'm partially not sure whether to put the C defines in enums or in
 *  constants (currently there's both, which is stupid).
 *  External feedback is highly appreciated.
 */

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
	flags:      c.int,   // 4.4 BSD field we dont use
}

Addrinfo :: struct {
	flags:     AddrinfoFlags,
	family:    AddrFamily,
	socktype:  Type,
	protocol:  c.int,
	addrlen:   c.uint,
	addr:      ^Addr,
	canonname: cstring,
	next:      ^Addrinfo,
}

AddrinfoFlags :: enum c.int {
	AI_PASSIVE     = 0x0001, // Socket address is intended for bind.
	AI_CANONNAME   = 0x0002, // Request for canonical name.
	AI_NUMERICHOST = 0x0004, // Don't use name resolution.
	AI_V4MAPPED    = 0x0008, // IPv4 mapped addresses are acceptable.
	AI_ALL         = 0x0010, // Return IPv4 mapped and IPv6 addresses.
	AI_ADDRCONFIG  = 0x0020, // Use configuration of this host to choose returned address type.
	AI_NUMERICSERV = 0x0400, // Don't use name resolution.
}

// Error values for getaddrinfo
AddrinfoError :: enum c.int {
	EAI_BADFLAGS   = -1,  // Invalid value for flags field.
	EAI_NONAME     = -2,  // NAME or SERVICE is unknown.
	EAI_AGAIN      = -3,  // Temporary failure in name resolution.
	EAI_FAIL       = -4,  // Non-recoverable failure in name resolution.
	EAI_NODATA     = -5,  // No address associated with NAME.
	EAI_FAMILY     = -6,  // family not supported.
	EAI_SOCKTYPE   = -7,  // socktype not supported.
	EAI_SERVICE    = -8,  // SERVICE not supported for socktype.
	EAI_ADDRFAMILY = -9,  // Address family for NAME not supported.
	EAI_MEMORY     = -10, // Memory allocation failure.
	EAI_SYSTEM     = -11, // System error returned in errno.
	EAI_OVERFLOW   = -12, // Argument buffer overflow.
}

// NOTE(renehsz): These are apparently GNU extensions... not sure if they are portable
EAI_INPROGRESS  :: -100; // Processing request in progress.
EAI_CANCELED    :: -101; // Request canceled.
EAI_NOTCANCELED :: -102; // Request not canceled.
EAI_ALLDONE     :: -103; // All request done.
EAI_INTR        :: -104; // Interrupted by a signal.
EAI_IDN_ENCODE  :: -105; // IDN encoding failed.

Ifaddrs :: struct {
	next:     ^Ifaddrs, // Next item in list
	name:     cstring,  // Name of interface
	flags:    c.uint,   // Flags from SIOCGIFFLAGS
	addr:     ^Addr,    // Address of interface
	netmask:  ^Addr,    // Netmask of interface
	ifu_addr: ^Addr,    /* Broadcast address of interface if IFF_BROADCAST is set or
	                     * point-to-point destination address if IFF_POINTTOPOINT is set
	                     * in flags */
	data:     rawptr,
}

NI_NUMERICHOST :: 1;
NI_NUMERICSERV :: 2;

Hostent :: struct {
	name:      cstring,  // The official name of the host
	aliases:   ^cstring, // An array of alternative names for the host, terminated by a null pointer
	addrtype:  c.int,    // The type of address; always AF_INET or AF_INET6 at present.
	length:    c.int,    // The length of the address in bytes.
	addr_list: ^cstring, // An array of pointers to network addresses for the host (in network byte order), terminated by a null pointer.
}

Protoent :: struct {
	name:    cstring,  // official protocol name
	aliases: ^cstring, // alias list
	proto:   c.int,    // protocol #
}

Serevent :: struct {
	name:    cstring,  // official service name
	aliases: ^cstring, // alias list
	port:    c.int,    // port #
	proto:   cstring,  // protocol to use
}

Netent :: struct {
	name:     cstring,
	aliases:  ^cstring,
	addrtype: c.int,
	net:      c.ulong,
}

Rpcent :: struct {
	name:    cstring,
	aliases: ^cstring,
	proto:   c.int,
}

SOMAXCONN :: 128;

@(default_calling_convention="c")
foreign libc {
	h_errno: c.int;

	socket        :: proc(domain: AddrFamily, typ: Type, protocol: c.int) -> os.Handle ---;
	accept        :: proc(sockfd: os.Handle, addr: ^Addr, addrlen: c.uint) -> os.Handle ---;
	accept4       :: proc(sockfd: os.Handle, addr: ^Addr, addrlen: c.uint, flags: c.int) -> os.Handle ---;
	bind          :: proc(sockfd: os.Handle, addr: ^Addrin, addrlen: c.uint) -> c.int ---;
	connect       :: proc(sockfd: os.Handle, addr: ^Addr, addrlen: c.uint) -> c.int ---;
	getsockname   :: proc(sockfd: os.Handle, addr: ^Addr, addrlen: c.uint) -> c.int ---;
	listen        :: proc(sockfd: os.Handle, backlog: c.int) -> c.int ---;
	getifaddrs    :: proc(ifap: ^Ifaddrs) -> c.int ---;
	freeifaddrs   :: proc(ifa: Ifaddrs) ---;
	getaddrinfo   :: proc(node, service: cstring, hints: ^Addrinfo, res: ^^Addrinfo) -> AddrinfoError ---;
	freeaddrinfo  :: proc(res: ^Addrinfo) ---;
	getnameinfo   :: proc(addr: ^Addr, addrlen: c.uint, host: cstring, hostlen: c.uint, serv: cstring, servlen: c.uint, flags: c.int) -> c.int ---;
	gai_strerror  :: proc(res: ^Addrinfo) -> cstring ---;
	gethostbyname :: proc(name: cstring) -> ^Hostent ---;
	gethostbyaddr :: proc(addr: rawptr, len: c.uint, typ: c.int) -> ^Hostent ---;
	sethostent    :: proc(stayopen: c.int) ---;
	endhostent    :: proc() ---;
	herror        :: proc(s: cstring) ---;
	hstrerror     :: proc(err: c.int) -> cstring ---;
	gethostent    :: proc() -> ^Hostent ---;

	htonl         :: proc(hostlong: u32) -> u32 ---;
	htons         :: proc(hostshort: u16) -> u16 ---;
	ntohl         :: proc(netlong: u32) -> u32 ---;
	ntohs         :: proc(netshort: u16) -> u16 ---;
}

HostErrno :: enum c.int {
	HOST_NOT_FOUND = 1,       // Authoritive Answer Host not found
	TRY_AGAIN      = 2,       // Non-Authoritive Host not found, or SERVERFAIL
	NO_RECOVERY    = 3,       // Non recoverable errors, FORMERR, REFUSED, NOTIMP
	NO_DATA        = 4,       // Valid name, no data record of requested type
	NO_ADDRESS     = NO_DATA, // no address, look for MX record
}

// h_errno :: HostErrno; TODO(renehsz): this is a foreign C variable, how do we declare that in Odin?


// Linux error codes, should go into core
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

