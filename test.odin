package main

using import "sock"
import "core:c"
import "core:os"

main :: proc() {
	serv_addr: Addrin;

	listenfd := socket(AddrFamily.INET, Type.STREAM, 0);

	serv_addr.family = cast(c.short) AddrFamily.INET;
	serv_addr.addr.addr = cast(c.ulong) htonl(0);
	serv_addr.port = htons(8080);

	bind(listenfd, &serv_addr, size_of(serv_addr));

	listen(listenfd, 10);

	for {
		connfd := accept(listenfd, nil, 0);

		os.write_string(cast(os.Handle)connfd, "Hello, sailor!\n");

		os.close(cast(os.Handle) connfd);
	}
}
