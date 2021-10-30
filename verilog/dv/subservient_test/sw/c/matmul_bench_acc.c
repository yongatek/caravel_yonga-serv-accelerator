#pragma GCC optimize("Os,no-unroll-loops,no-peel-loops")
/*
    riscv64-unknown-elf-gcc matmul_bench_acc.c utility.c -o matmul_bench_acc.elf -nostdlib -march=rv32i -mabi=ilp32 -T ../linkc.ld -Os -ffunction-sections 
    riscv64-unknown-elf-objcopy -O binary matmul_bench_acc.elf matmul_bench_acc.bin
    python ../py_tools/subservient_makehex.py matmul_bench_acc.bin 1024 > matmul_bench_acc_subservient.hex
    python ../py_tools/makehex.py matmul_bench_acc.bin 256 > matmul_bench_acc_servant.hex
    riscv64-unknown-elf-objdump -D matmul_bench_acc.elf > elfdump.txt

*/
#include "memory_map.h"
#include "utility.h"
#include "random_arrays.h"

void matmul(const signed char*,const signed char*);

int entry_point() {

    tic();
    matmul(DATA_0,DATA_1);
    GPIO_0 = toc();
    for(char i = 0; i<FMRS; i++){
        for(char j = 0; j<FMCS; j++){
            if(DATA_2(i,j) != TM(i,j)){
                failed();
            }
        }
    }
    passed();
}

void matmul(const signed char* DATA_0, const signed char* DATA_1){
    for(char i = 0; i<FMRS; i++){
        for(char j = 0; j<FMCS; j++){
            FM(i,j) =  DATA_0(i,j);
            SM(i,j) =  DATA_1(i,j);
        }
    }
    ACC_RW(ADR_CONTROL_BASE) = DATA_START;
    ACC_RW(ADR_CONTROL_BASE) = DATA_STOP;
    while(!ACC_RW(ADR_FINISHED)){}
}
