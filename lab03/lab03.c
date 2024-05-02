int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall write code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (64) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}

int char_to_hex(char num) {
  if (num >= '0' && num <= '9')
    return num - '0';
  else return num -'a' + 10;
}

int lenght(char *str) {
  int i = 0;
  while (str[i] != '\n') {
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

void copia_string(char *str1, char *str2) {
  // copia str1 em str2
  int len = lenght(str1);
  for (int i = 0; i < len + 1; i++)
    str2[i] = str1[i];
}

unsigned int string_to_int(const char *str) {
  unsigned int result = 0;
  
  if (str[0] == '-') {
    str++;
  }

  while (*str != '\n') {
    if (*str >= '0' && *str <= '9') {
      result = result * 10 + (*str - '0');
      str++;
    }
  }
  return result;
}

unsigned int string_to_hex(const char *str) {
  unsigned int result = 0;

  if (str[0] == '0' || str[1] == 'x') str += 2; //Pula o "0x"

  while (*str != '\n') {
    int digit = char_to_hex(*str);
    result = result * 16 + digit;
    str++;
  }
  return result;
}

void dec_to_bin(unsigned int num, char *bin) { // somente números positivos
    int i = 0;

    if (num == 0) {
      bin[0] = '0';
      bin[1] = '\n';
      return;
    }

    if (*bin == '-') bin++;

    while (num > 0) { 
        bin[i] = (num % 2) + '0';
        num /= 2;
        i++;
    } bin[i] = '\n';

    int len = i;
    for (int j = 0; j < len/2; j++) {
        char temp = bin[j];
        bin[j] = bin[len - j - 1];
        bin [len - j - 1] = temp;
    }
}

void dec_to_hex(unsigned int num, char *hex) {
  int index = 0;

  if (num == 0) {
    hex[0] = '0';
    hex[1] = '\n';
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

  hex[index] = '\n';
}

unsigned int bin_to_dec(char *bin) {
  unsigned int result = 0;
  unsigned int base = 1;
  int len = lenght(bin);

  for (int i = len - 1; i >= 0; i--) {
    if (bin[i] == '1')
      result += base;
    base *= 2;
  }
  return result;
}

void dec_to_string(unsigned int num, char *str) {
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
    if (bin[i] == '0') {
      bin[i] = '1';
    } else if (bin[i] == '1') {
      bin[i] = '0';
    }
  }


  for (int j = 0; j < 16; j++) {
      char temp = bin[j];
      bin[j] = bin[31 - j];
      bin [31 - j] = temp;
  }
  
  bin[32] = '\n';
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

#define STDIN_FD  0
#define STDOUT_FD 1

int main() {
  char entrada[20];
  int n = read(STDIN_FD, entrada, 20);    // leitura da entrada
  char tipo = 'd';                        // tipo da variável de entrada
  int sinal = 0;                          // indica se num é positivo ou negativo 
  unsigned int num, num_dec;              // num armazena o número int da entrada e num_dec é um auxiliar
  char bin[35];                           // armazena o número de entrada em binário
  char hex[20];                           // armazena a string decimal 
  char saida_bin[35];                     // primeira saída (conversão binária)
  char saida_dec[20];                     // segunda saída (decimal correspondente)
  char saida_hex[20];                     // terceira saída (hexa correspondente)
  char saida_invert[20];                  // quarta saída (inversão do endianness)

  if (entrada[1] == 'x') tipo = 'h';      // hexa ou decimal

  if (tipo == 'd') {
    num = string_to_int(entrada);
  }
  else if (tipo == 'h') {
    num = string_to_hex(entrada);
  }

  dec_to_bin(num, bin);                     // converte binário da entrada
  copia_string(bin, saida_bin);             // cria uma cópia para modificação

  if (entrada[0] == '-') {                  // primeira verificação do negativo
    int len = lenght(saida_bin);  
    complemento_de_dois(saida_bin, len);
    sinal = 1;
  }

  append_left(saida_bin, 'b');                // formata e imprime a primeira saída
  append_left(saida_bin, '0');
  write(STDOUT_FD, (void*) saida_bin, 35);

  num_dec = bin_to_dec(saida_bin);
  dec_to_hex(num_dec, hex);                     // armaena o hexa da primeira saída

  copia_string(bin, saida_bin);                 // traz o binário original
  if (lenght(bin) == 32) {                      // len = 32 <-> número maior que 0x80000000, ou seja é
    sinal = 1;                                  // negativo. Se len < 32 os zeros à esquerda não aparecem
    complemento_de_dois(saida_bin, 32);
    num_dec = bin_to_dec(saida_bin);
    dec_to_string(num_dec, saida_dec);          // transforma em string o comlemento de dois se negativo
  } else {
    dec_to_string(num, saida_dec);              // ou o número original
  }
  
  if (sinal == 1) append_left(saida_dec, '-');  // formata caso negativo
  write(STDOUT_FD, saida_dec, 20);
  
  copia_string(hex, saida_hex);                 // formata e imprime uma cópia do hex original
  append_left(saida_hex, 'x');
  append_left(saida_hex, '0');
  write(STDOUT_FD, saida_hex, 20);

  invert_endianness(hex);                       // inverte a representação do hex original
  num_dec = string_to_hex(hex);                 // transforma em decimal e imprime
  dec_to_string(num_dec, saida_invert);
  write(STDOUT_FD, saida_invert, 20);

  return 0;
}

