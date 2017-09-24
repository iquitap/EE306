# This program brute forces possible configurations of two muxes to make them form an XOR.
# This solves question 5b of problem set 2:
# "Implement F = A xor B using ONLY two 2-to-1 muxes"
#
# I somehow coded the entire program without testing it once, and it worked perfectly
# on its first run. The code below has not been modified from its first version except
# for formatting edits and new comments being added.
#
# Credit to Andy and Bala for discussing with me how to create the program,
# and motivating me to be the first to implement it.
#
#       a     b
#   ____|_____|___
#  |              |
#  |      MUX     |-- s
#  |______________|
#

def mux(a, b, s):
    return (a and s) or (b and not s)

for mux1a in ('a', 'b', False, True): # A input of mux1
    for mux1b in ('a', 'b', False, True):
        for mux1s in ('a', 'b', False, True):
            for mux2a in ('a', 'b', False, True, 'mux1'):
                for mux2b in ('a', 'b', False, True, 'mux1'):
                    for mux2s in ('a', 'b', False, True, 'mux1'):
                        # possible values for each input (truth table)
                        truth = { # desired output F = (A XOR B)
                            #AB : F
                            "00":"0",
                            "01":"1",
                            "10":"1",
                            "11":"0"
                        }
                        success = 0
                        for a_val in (False, True):
                            for b_val in (False, True):
                                if mux1a == 'a':
                                    a = a_val
                                elif mux1a == 'b':
                                    a = b_val
                                else:
                                    a = mux1a

                                if mux1b == 'a':
                                    b = a_val
                                elif mux1b == 'b':
                                    b = b_val
                                else:
                                    b = mux1b

                                if mux1s == 'a':
                                    s = a_val
                                elif mux1s == 'b':
                                    s = b_val
                                else:
                                    s = mux1s

                                mux1 = mux(a, b, s)

                                if mux2a == 'a':
                                    a = a_val
                                elif mux2a == 'b':
                                    a = b_val
                                elif mux2a == 'mux1':
                                    a = mux1
                                else:
                                    a = mux2a

                                if mux2b == 'a':
                                    b = a_val
                                elif mux2b == 'b':
                                    b = b_val
                                elif mux2b == 'mux1':
                                    b = mux1
                                else:
                                    b = mux2b

                                if mux2s == 'a':
                                    s = a_val
                                elif mux2s == 'b':
                                    s = b_val
                                elif mux2s == 'mux1':
                                    s = mux1
                                else:
                                    s = mux2s

                                mux2 = mux(a, b, s)

                                if str(int(mux2)) == truth[str(int(a_val)) + str(int(b_val))]:
                                    success += 1

                        if success == 4:
                            print("Eureka!")
                            print(str(mux1a))
                            print(str(mux1b))
                            print(str(mux1s))
                            print(str(mux2a))
                            print(str(mux2b))
                            print(str(mux2s))
                            #exit()
