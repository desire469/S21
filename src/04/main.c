#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>


typedef struct {
    char ip[16];
    char timestamp[32];
    char method[8];
    char url[256];
    int status;
    char user_agent[64];
} LogEntry;


void generate_ip(char *ip) {
    int octet1 = rand() % 223 + 1;  
    int octet2 = rand() % 256;
    int octet3 = rand() % 256;
    int octet4 = rand() % 255 + 1;  
    sprintf(ip, "%d.%d.%d.%d", octet1, octet2, octet3, octet4);
}


void generate_url(char *url) {
    const char *paths[] = {
        "/", "/index.html", "/about", "/contact", "/products",
        "/api/v1/users", "/api/v1/data", "/images/logo.png",
        "/css/style.css", "/js/app.js", "/login", "/admin",
        "/blog/post/123", "/search", "/download/file.zip"
    };
    const char *queries[] = {
        "", "?page=1", "?sort=date", "?filter=active",
        "?id=123&token=abc", "?search=test"
    };
    
    int path_idx = rand() % (sizeof(paths) / sizeof(paths[0]));
    int query_idx = rand() % (sizeof(queries) / sizeof(queries[0]));
    
    sprintf(url, "%s%s", paths[path_idx], queries[query_idx]);
}


void generate_user_agent(char *agent) {
    const char *agents[] = {
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
        "Google Chrome/120.0.0.0 Safari/537.36",
        "Opera/9.80 (Windows NT 6.1) Presto/2.12.388 Version/12.18",
        "Safari/537.36 Version/4.0 Chrome/58.0.3029.83",
        "Internet Explorer/11.0",
        "Microsoft Edge/120.0.2210.91",
        "Crawler and bot (compatible; Googlebot/2.1)",
        "Library and net tool (curl/7.68.0)"
    };
    
    int idx = rand() % (sizeof(agents) / sizeof(agents[0]));
    strcpy(agent, agents[idx]);
}


void generate_log_entry(LogEntry *entry, time_t day_start) {
    
    generate_ip(entry->ip);
    
    
    
    time_t offset = rand() % 86400;
    time_t entry_time = day_start + offset;
    
    struct tm *timeinfo = gmtime(&entry_time);
    strftime(entry->timestamp, sizeof(entry->timestamp), 
             "%d/%b/%Y:%H:%M:%S +0000", timeinfo);
    
    
    const char *methods[] = {"GET", "POST", "PUT", "PATCH", "DELETE"};
    int method_idx = rand() % (sizeof(methods) / sizeof(methods[0]));
    strcpy(entry->method, methods[method_idx]);
    
    
    generate_url(entry->url);
    
    /*
    Коды ответа HTTP и их значения:
    200 - OK: Успешный запрос
    201 - Created: Ресурс успешно создан
    400 - Bad Request: Некорректный запрос
    401 - Unauthorized: Требуется аутентификация
    403 - Forbidden: Доступ запрещен
    404 - Not Found: Ресурс не найден
    500 - Internal Server Error: Внутренняя ошибка сервера
    501 - Not Implemented: Метод не поддерживается
    502 - Bad Gateway: Ошибка шлюза
    503 - Service Unavailable: Сервис временно недоступен
    */
    int status_codes[] = {200, 201, 400, 401, 403, 404, 500, 501, 502, 503};
    int status_idx = rand() % (sizeof(status_codes) / sizeof(status_codes[0]));
    entry->status = status_codes[status_idx];
    
    
    
    generate_user_agent(entry->user_agent);
}


void generate_log_file(const char *filename, time_t day_start) {
    FILE *file = fopen(filename, "w");
    if (!file) {
        printf("Error opening file %s\n", filename);
        return;
    }
    
    
    int num_entries = rand() % 901 + 100;
    
    LogEntry *entries = malloc(num_entries * sizeof(LogEntry));
    
    
    for (int i = 0; i < num_entries; i++) {
        generate_log_entry(&entries[i], day_start);
    }
    
    
    
    for (int i = 0; i < num_entries - 1; i++) {
        for (int j = 0; j < num_entries - i - 1; j++) {
            
            
            
            if (rand() % 2 == 0) { 
                LogEntry temp = entries[j];
                entries[j] = entries[j + 1];
                entries[j + 1] = temp;
            }
        }
    }
    
    for (int i = 0; i < num_entries; i++) {
        fprintf(file, "%s - - [%s] \"%s %s HTTP/1.1\" %d \"-\" \"%s\"\n",
                entries[i].ip,
                entries[i].timestamp,
                entries[i].method,
                entries[i].url,
                entries[i].status,
                entries[i].user_agent);
    }
    
    free(entries);
    fclose(file);
}

int main() {
    time_t now = time(NULL);
    struct tm *timeinfo = gmtime(&now);
    
    
    for (int i = 0; i < 5; i++) {
        
        time_t day_start = now - (i * 86400);
        struct tm *day_info = gmtime(&day_start);
        day_info->tm_hour = 0;
        day_info->tm_min = 0;
        day_info->tm_sec = 0;
        day_start = mktime(day_info) - timezone;
        
        
        char filename[32];
        strftime(filename, sizeof(filename), "access_%Y-%m-%d.log", day_info);
        
        
        generate_log_file(filename, day_start);
        
    }
    

    return 0;
}