import "socket.odin";
import "core:os.odin"
using import "core:c.odin"

main :: proc() {
	serv_addr: socket.Addrin;

	listenfd := socket.socket(socket.AddrFamily.INET, socket.Type.STREAM, 0);

	serv_addr.family = cast(c_short)socket.AddrFamily.INET;
	serv_addr.addr.addr = cast(c_ulong)socket.htonl(0);
	serv_addr.port = socket.htons(8080);

	socket.bind(listenfd, &serv_addr, size_of(serv_addr));

	socket.listen(listenfd, 10);

	for {
		connfd := socket.accept(listenfd, nil, 0);

		os.write_string(cast(os.Handle)connfd, "Hello, sailor!\n");

		os.close(cast(os.Handle)connfd);
	}
}
