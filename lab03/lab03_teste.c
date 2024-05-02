#include <stdio.h>

int char_to_int(char num) {
  int num_int = num - '0';
  return num_int;
}

char int_to_char(int num) {
  char num_char = num + '0';
  return num_char;
}

int char_to_hex(char num) {
  if (num >= '0' && num <= '9')
    return num - '0';
  else return num -'a' + 10;
}

long int string_to_int(const char *str) {
  long int result = 0;
  
  if (*str == '-') {
    str++;
  }

  while (*str != '\0') {
    if (*str >= '0' && *str <= '9') {
      result = result * 10 + (*str - '0');
      str++;
    }
  }
  return result;
}

long int string_to_hex(const char *str) {
  long int result = 0;

  if (str[0] == '0' || str[1] == 'x') str += 2; //Pula o "0x"

  while (*str != '\0') {
    int digit = char_to_hex(*str);
    result = result * 16 + digit;
    str++;
  }

  return result;
}

int lenght(char *str) {
  int i = 0;
  while (str[i] != '\0') {
    i++;
  }
  return i;
}

void append_left(char *str, char new) {
  int len = lenght(str);
  for (int i = len; i >= 0; i--) {
    str[i + 1] = str[i];
  }
  str[0] = new;
}

void dec_to_bin(long int num, char *bin) { // sonmente números positivos
  int i = 0;
  int flag = 0;

  if (num == 0) {
    bin[0] = '0';
    bin[1] = '\0';
  }

  while (num > 0) { 
    bin[i] = (num % 2) + '0';
    num /= 2;
    i++;
  } bin[i] = '\0';

  int len = i;
  for (int j = 0; j < len/2; j++) {
    char temp = bin[j];
    bin[j] = bin[len - j - 1];
    bin [len - j - 1] = temp;
  }
}

void flip_bits(char *bin, int len) {

  for (int j = 0; j < len/2; j++) {
    char temp = bin[j];
    bin[j] = bin[len - j - 1];
    bin [len - j - 1] = temp;
  }

  for (int i = len; i < 32; i++) {
    bin[i] = '0';
  }

  for (int i = 0; i < 32; i++) {
      if (bin[i] == '0')
          bin[i] = '1';
      else if (bin[i] = '1')
          bin[i] = '0';
  }

  bin[32] = '\0';

  for (int j = 0; j < 16; j++) {
      char temp = bin[j];
      bin[j] = bin[31 - j];
      bin [31 - j] = temp;
  }
}

void soma_um(char *bin) {
    int carry = 1;

    for (int i = 31; i >= 0; i--) {
        if (bin[i] == '0' && carry == 1) {
            bin[i] = '1';;
            carry = 0;
        } else if (bin[i] == '1' && carry == 1)
            bin[i] = '0';
    }
}

void complemento_de_dois(char *bin, int len) {
    flip_bits(bin, len);
    soma_um(bin);
}

long int bin_to_dec (char *bin) {
  long int result = 0;
  long int base = 1;
  int len = lenght(bin);

  for (int i = len - 1; i >= 0; i--) {
    if (bin[i] == '1')
      result += base;
    base *= 2;
  }
  return result;
}

void dec_to_hex (long int num, char *hex) {
  int index = 0;

  if (num == 0) {
    hex[0] = '0';
    hex[1] = '\0';
    return;
  }

  while (num > 0) {
    int resto = num % 16;
    if (resto < 10) {
      hex[index] = resto + '0';
    } else {
      hex[index] = resto - 10 + 'a';
    }
    num /= 16;
    index++;
  }

  int len = lenght(hex);

  for (int j = 0; j < index/2; j++) {
    char temp = hex[j];
    hex[j] = hex[index - j - 1];
    hex[index - j - 1] = temp;
    }

  hex[index] = '\0';
}

void invert_endianness(char *hex) {

  int len = lenght(hex);        // corrige o tamanho do hex para oito dígitos
  while (len < 8) {
    append_left(hex, '0');
    len = lenght(hex);    
  }

  char temp = hex[0];
  hex[0] = hex[6];
  hex[6] = temp;      // troca primeiro com sétimo dígito
  temp = hex[1];
  hex[1] = hex[7];
  hex[7] = temp;      // troca segundo com último dígito
  temp = hex[2];
  hex[2] = hex[4];
  hex[4] = temp;      // troca terceiro com quinto dígito
  temp = hex[3];
  hex[3] = hex[5];
  hex[5] = temp;      // troca quarto com sexto dígito

}

void dec_to_string(long int num, char *str) {
  int index = 0;

  if (num == 0) {
    str[index] = '0';
    str[index + 1] = '\0';
    return;
  }

  while (num > 0) {
    str[index] = (num % 10) + '0';
    num /= 10;
    index++;
  }
  str[index] = '\0';

  int len = lenght(str);  

  for (int i = 0; i < len / 2; i++) {
    char temp = str[i];
    str[i] = str[len - i - 1];
    str[len - i - 1] = temp;
  }
}

void copia_string(char *str1, char *str2) {
  // copia str1 em str2
  int len = lenght(str1);
  for (int i = 0; i < len + 1; i++)
    str2[i] = str1[i];
}

int main() {

    char entrada[] = "-200";
    char tipo = 'd';  // indica a base em que o número de entrada está
    long int num = 0;
    int sinal = 0;  // sinal inicialmente positivo
    char bin[35];   // string que armazena o número em binário
    char hex[20];   // string em que o decimal de saída sera armazenado
    char saida[35];
    
    if (entrada[1] == 'x') tipo = 'h'; 

    if (tipo == 'd')
        num = string_to_int(entrada);
    else if (tipo == 'h')
        num = string_to_hex(entrada);   // valor decimal do número armazenado

    dec_to_bin(num, bin);               // cria a string binária do número
    copia_string(bin, saida);

    if (entrada[0] == '-') {
      int len = lenght(saida);
      complemento_de_dois(saida, len);
      sinal = 1;
    }

    append_left(saida, 'b');
    append_left(saida, '0');
    printf("%s\n", saida);              // imprime binário
    copia_string(bin, saida);

    if (lenght(bin) == 32 && tipo == 'h') {  // se len=32 o número é negativo
      sinal = 1;
      complemento_de_dois(saida, 32);
      num = bin_to_dec(saida);
    };   
    dec_to_string(num, saida);
    if (sinal == 1) printf("-%s\n", saida);
    else printf("%s\n", saida);

    long int converte = bin_to_dec(bin);  // converte o binal para dec
    dec_to_hex(converte, hex);            // e dec para hex
    printf("0x%s\n", hex);

    invert_endianness(hex);
    converte = string_to_hex(hex);
    char string_saida[33];
    dec_to_string(converte, string_saida);
    printf("%s\n", string_saida);

    return 0;
}