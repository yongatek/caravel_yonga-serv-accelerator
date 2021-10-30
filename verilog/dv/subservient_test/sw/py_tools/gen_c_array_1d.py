from sys import argv
from contextlib import redirect_stdout
from random import randint
import numpy as np

# generate two RxC matrices and their multiplication
# $ python c_array_gen.py 16 16 > data.txt

RS = 8
CS = 8
fm_np = np.random.randint(-128,127, size=(RS, CS))
sm_np = np.random.randint(-128,127, size=(RS, CS))
verify_np = np.zeros((RS,CS))
def create_c_array(RS,CS,rnd_matrix,nm):
    print(f'static const signed char DATA_{nm}[{RS*CS}] = ',end='')
    for row in range(0,RS):
        if(row == 0):
            print('{',end='')
        else:
            print('                                       ',end='')
        for column in range(0,CS-1):
            r_int = rnd_matrix[row,column]
            print("{0:>6}".format(r_int) + ',',end='')
        r_int = rnd_matrix[row,column+1]
        print("{0:>6}".format(r_int) ,end='')
        if(row == RS-1):
            print("};")
        else:
            print(',')
create_c_array(RS,CS,fm_np,0)
print('',end='\n')
create_c_array(RS,CS,sm_np,1)
print('',end='\n')
verify_np = np.matmul(fm_np, sm_np)
create_c_array(RS,CS,verify_np,2)
