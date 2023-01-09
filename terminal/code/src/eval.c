#include<klib.h>
#define _BUFFER_SIZE 32

char buf[_BUFFER_SIZE << 1];
char suf[_BUFFER_SIZE << 1];
int num_stack[_BUFFER_SIZE];
char op_stack[_BUFFER_SIZE];

int error = 0;
int op_top = -1, num_top = -1;

int is_digit(char c) {
    return ('0' <= c && c <= '9');
}

int oper_level(char oper) {
    switch (oper) {
        case '#': return 4;
        case '^': return 3;
        case '*': return 2;
        case '/': return 2;
        case '+': return 1;
        case '-': return 1;
        case '(': return 0;
        case ')': return 0;
        default:  return -1;
    }
};

void handle_error() {
    puts("Invalid expression");
    putch('\n');
    error = 1;
}

void normalize() {
    size_t len = strlen(buf);
    if (buf[0] == '-') buf[0] = '#';
    for (size_t i = 0; i != len; ++i) {
        if (buf[i] == '(') {
            if (i + 1 < len) {
                if (buf[i + 1] == '-') {
                    buf[i + 1] = '#';
                }
            } else goto ERROR;
        }
    }
    return;

    ERROR: handle_error();
}

void convert() {
    size_t len = strlen(buf), tot = 0;
    for (size_t i = 0; i != len; ++i) {
        if (buf[i] == ' ') continue;
        else if (is_digit(buf[i])) {
            while (is_digit(buf[i])) {
                suf[tot++] = buf[i];
                i++;
            } i--;
            suf[tot++] = ' ';
        } else if (buf[i] == '(') {
            op_stack[++op_top] = '(';
        } else if (buf[i] == ')') {
            while (op_top >= 0 && op_stack[op_top] != '(') {
                suf[tot++] = op_stack[op_top];
                suf[tot++] = ' ';
                op_top--;
            }
            op_top--;
        } else {
            if (oper_level(buf[i]) == -1) {
                goto ERROR;
            }
            while (op_top >= 0 && oper_level(op_stack[op_top]) >= oper_level(buf[i])) {
                suf[tot++] = op_stack[op_top];
                suf[tot++] = ' ';
                op_top--;
            }
            op_stack[++op_top] = buf[i];
        }
    }
    while (op_top >= 0) {
        suf[tot++] = op_stack[op_top];
        suf[tot++] = ' ';
        op_top--;
    }
    suf[tot++] = '\0';
    return;

    ERROR: handle_error();
}

int qpow(int x, int n) {
    int res = 1;
    while (n) {
        if (n & 1) res *= x;
        x *= x;
        n >>= 1;
    }
    return res;
}

int evaluate() {
    size_t len = strlen(suf);
    for (size_t i = 0; i != len; ++i) {
        if (is_digit(suf[i])) {
            int res = 0;
            while (is_digit(suf[i])) {
                res = (res << 1) + (res << 3) + suf[i++] - 48;
            }
            num_stack[++num_top] = res;
        } 
        else if (suf[i] == '#') {
            int op; i++;
            if (num_top >= 0) op = num_stack[num_top--];
            num_stack[++num_top] = -op;
        } else {
            int op1, op2;
            char oper = suf[i++];
            if (num_top >= 0) op2 = num_stack[num_top--];
            else goto ERROR;
            if (num_top >= 0) op1 = num_stack[num_top--];
            else goto ERROR;

            switch (oper) {
                case '^': num_stack[++num_top] = qpow(op1, op2); break;
                case '*': num_stack[++num_top] = op1 * op2; break;
                case '/': num_stack[++num_top] = op1 / op2; break;
                case '+': num_stack[++num_top] = op1 + op2; break;
                case '-': num_stack[++num_top] = op1 - op2; break;
                default: goto ERROR;
            }
        }
    }
    
    return num_stack[num_top];

    ERROR: handle_error(); return 0;
}

void eval() {
    int res;
    puts("Please enter the expression: ");
    gets(buf);
    if (!error) normalize();
    if (!error) convert();
    if (!error) res = evaluate();
    if (!error) {printf("    = %d", res); putch('\n');};
    return;
}