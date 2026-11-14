import http.server, socketserver

PORT = 8080
Handler = http.server.SimpleHTTPRequestHandler

class ThreadingHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True

if __name__ == '__main__':
    with ThreadingHTTPServer(('127.0.0.1', PORT), Handler) as httpd:
        print(f"Solavanta Careers local server running at http://localhost:{PORT}")
        httpd.serve_forever()
