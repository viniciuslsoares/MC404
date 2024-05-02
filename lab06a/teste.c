#include <stdio.h>

int sqrt_(int n, int iteration) {

    int out = n / 2;
    int k;
    for (int i = 0; i < iteration; i++) {
        k = (out + n/out)/2;
        out = k;
    }
    return out;
}

void copy_num(const char *entrada, char *num, int index) {
    for (int i = 0; i < 4; i++) {
        char temp = entrada[i + index];
        num[i] = temp;
    }
    num[4] = '\n';
}

int string_to_int(const char *str) {
  int result = 0;

  while (*str != '\n') {
    if (*str >= '0' && *str <= '9') {
      result = result * 10 + (*str - '0');
      str++;
    }
  }
  return result;
}

void dec_to_string(int num, char *str) {
  int index = 0;

  if (num == 0) {
    str[index] = '0';
    str[index + 1] = '\n';
    return;
  }

  while (num > 0) {
    str[index] = (num % 10) + '0';
    num /= 10;
    index++;
  }
  str[index] = '\n';

  int len = lenght(str);  

  for (int i = 0; i < len / 2; i++) {
    char temp = str[i];
    str[i] = str[len - i - 1];
    str[len - i - 1] = temp;
  }
}

int main() {

    char entrada[20] = "0400 5337 2240 9166\n";
    char aux[5];
    int nums[4];

    for (int i = 0; i < 4; i++) {
        copy_num(entrada, aux, i * 5);
        nums[i] = string_to_int(aux);
    }

    for (int i = 0; i < 4; i++) {
        printf("%d\n", sqrt_(nums[i], 10));
    }


    return 0;
}