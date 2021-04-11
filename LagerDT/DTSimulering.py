def decTree(liste):
    if liste[3] <= -1.5:
        if liste[3] <= -3.5:
            if liste[8] <= -0.5:
                print("weights: [0.00, 0.00, 1.00] class: svart")
            else:
                print("weights: [1.00, 0.00, 0.00] class: lysegraa")
        else:
            print("weights: [0.00, 4.00, 0.00] class: moerkegraa")
    else:
        if liste[5] <= -0.5:
            print("weights: [0.00, 0.00, 3.00] class: svart")
        else:
            if liste[6] <= -1.0:
                if liste[0] <= -1.5:
                    print("weights: [0.00, 0.00, 1.00] class: svart")
                else:
                    print("weights: [0.00, 1.00, 0.00] class: moerkegraa")
            else:
                print("weights: [4.00, 0.00, 0.00] class: lysegraa")

if __name__ == "__main__":
    print("Alle her skal være svarte")
    decTree([0, -2, -5, -6, 2, 2, 2, 3, -2])
    decTree([-2, 0, 0, 2, 1, 0, -2, 0, -2])
    decTree([2, 0, -1, 0, 0, -1, 0, 0, 0])
    decTree([-4, -6, 1, 1, -4, -4, 4, 5, 4])
    decTree([-1, -5, -2, 3, -1, -1, 0, 1, 0])
    decTree([2, -3, -1, -1, 0, -1, -1, -2, 1])
    decTree([4, 1, 1, -1, 1, -1, -1, 1, 2])
    decTree([3, 3, 0, 0, 1, -2, -2, -2, 1])

    print("\nAlle her skal være mørkegrå")
    decTree([-1, -2, 1, 0, 1, 2, -5, -2, 1])
    decTree([-2, -4, -6, -2, -1, -2, -3, 1, -2])
    decTree([0, -1, -5, -3, 4, 1, -2, -1, -6])
    decTree([-1, 0, -2, -2, -1, -2, 1, 1, 0])
    decTree([-3, 2, -1, -3, 0, -1, -2, 1, 2])
    decTree([1, 0, 1, 0, -1, -2, -2, 0, 0])
    decTree([1, -2, 1, -1, 1, -2, 1, 1, 0])

    print("\nAlle her skal være lysegrå")
    decTree([0, -1, -3, -4, -4, -4, -3, -3, 0])
    decTree([-1, -6, -15, -12, -10, -8, -10, -10, -8])
    decTree([1, 1, -2, -4, -3, -5, -6, -7, -7])
    decTree([-2, -5, -2, 0, 1, 1, 1, -1, -2])
    decTree([0, 0, -1, -5, -4, -1, -3, -5, -4])
    decTree([5, 7, 9, 11, 13, 13, 14, 15, 15])
    decTree([8, 12, 11, 19, 24, 25, 26, 26, 27])
    decTree([1, 2, 1, -1, -3, -6, -8, -12, -9])
