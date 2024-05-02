#include <stdio.h>

void hex_code(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;
    
    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    printf("%s", hex);
}

void copy_num(const char *entrada, char *num, int index) {
    for (int i = 0; i < 6; i++) {
        char temp = entrada[i + index];
        num[i] = temp;
    }
    num[5] = '\0';
}

int string_to_int(const char *str) {
  int result = 0;
  int signal = 1;
  
  if (str[0] == '-') {
    str++;
    signal = -1;
  } else if (str[0] == '+') str++;

  while (*str != '\0') {
    if (*str >= '0' && *str <= '9') {
      result = result * 10 + (*str - '0');
      str++;
    }
  }
  return signal * result;
}

int power(int num, int exp) {
    int saida = 1;
    for (int i = 0; i < exp; i++) {
        saida *= num;
    }
    return saida;
}

void pack(int input, int start_bit, int end_bit, int*val) {
    int masc = power(2, end_bit - start_bit + 1) - 1;
    masc = masc & input;
    //printf("%d\n", masc);
    masc = (masc << start_bit);
    printf("%d\n", masc);
    *val = *val | masc;
}

int main() {

    char entrada[30] = "+9999 +9999 +9999 +9999 +9999\n";
    char aux[6];
    int nums[5];
    for (int i = 0; i < 5; i++) {
        copy_num(entrada, aux, i * 6);
        nums[i] = string_to_int(aux);
        printf("%d\n", nums[i]);
    }
    unsigned int output_dec = 0;
    pack(nums[0], 0, 2, &output_dec);
    pack(nums[1], 3, 10, &output_dec);
    pack(nums[2], 11, 15, &output_dec);
    pack(nums[3], 16, 20, &output_dec);
    pack(nums[4], 21, 31, &output_dec);

    hex_code(output_dec);

    return 0;
}