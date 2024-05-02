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

#define STDIN_FD  0
#define STDOUT_FD 1

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
    write(1, hex, 11);
    }

void copy_num(const char *entrada, char *num, int index) {
    for (int i = 0; i < 6; i++) {
        char temp = entrada[i + index];
        num[i] = temp;
    }
    num[5] = '\n';
}

int string_to_int(const char *str) {
  int result = 0;
  int signal = 1;
  
  if (str[0] == '-') {
    str++;
    signal = -1;
  } else if (str[0] == '+') str++;

  while (*str != '\n') {
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
    masc = (masc << start_bit);
    *val = *val | masc;
}


int main()
{
    char entrada[30];
    char aux[6];
    int nums[5];

    int n = read(STDIN_FD, entrada, 30);
    for (int i = 0; i < 5; i++) {
        copy_num(entrada, aux, i * 6);
        nums[i] = string_to_int(aux);
    }
    int output_dec = 0;
    pack(nums[0], 0, 2, &output_dec);
    pack(nums[1], 3, 10, &output_dec);
    pack(nums[2], 11, 15, &output_dec);
    pack(nums[3], 16, 20, &output_dec);
    pack(nums[4], 21, 31, &output_dec);

    hex_code(output_dec);

    return 0;
}
