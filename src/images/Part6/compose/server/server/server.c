#include <fcgi_stdio.h>
#include <stdlib.h>

int main() {
    while (FCGI_Accept() >= 0) {
        printf("Content-Type: text/html\r\n"
               "\r\n"
               "<html>\n"
               "<head><title>Hello, World!</title></head>\n"
               "<body>\n"
               "<h1>Hello, World!</h1>\n"
               "</body>\n"
               "</html>\n");
    }
    return 0;
}