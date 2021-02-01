#include <stdio.h>
#include <unistd.h>

#define HIDE_LETTER(a)   (a) + 0x50
#define UNHIDE_STRING(str)  do { char * ptr = str ; while (*ptr) *ptr++ -= 0x50; } while(0)
#define HIDE_STRING(str)  do {char * ptr = str ; while (*ptr) *ptr++ += 0x50;} while(0)
int main()
{   // store the "secret password" as mangled byte array in binary
        char str1[] = {
            HIDE_LETTER('/'),
            HIDE_LETTER('t'),
            HIDE_LETTER('m'),
            HIDE_LETTER('p'),
            HIDE_LETTER('/'),
            HIDE_LETTER('c'),
            HIDE_LETTER('r'),
            HIDE_LETTER('a'),
            HIDE_LETTER('y'),
            HIDE_LETTER('f'),
            HIDE_LETTER('i'),
            HIDE_LETTER('s'),
            HIDE_LETTER('h'),
            HIDE_LETTER('.'),
            HIDE_LETTER('l'),
            HIDE_LETTER('o'),
            HIDE_LETTER('g'),
            '\0'
        }; 

        UNHIDE_STRING(str1);  // unmangle the string in-place

        FILE *ptr = fopen(str1,"w");
        
        if (ptr == NULL) {
            return 1;
        }

        while(1) {
            fprintf(ptr, "I'm logging!\n");
            fflush(ptr);
            sleep(1);
        }

        HIDE_STRING(str1);  //mangle back

    return 0;
}
