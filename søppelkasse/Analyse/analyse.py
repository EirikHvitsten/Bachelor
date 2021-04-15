import matplotlib.pyplot as plt
import numpy as np
from scipy.interpolate import make_interp_spline, BSpline

# Indexes are seconds, common for all, can also be different between the measurements
    # We probably want the total to be that same though?
time = [0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64, 68, 72, 76, 80, 84, 88, 92, 96, 100, 104, 108, 112, 116, 120, 124, 
    128, 132, 136, 140, 144, 148, 152, 156, 160, 164, 168, 172, 176, 180, 184, 188, 192, 196, 200]

black = [138, 140, 142, 143, 144, 145, 146, 147, 148, 149, 150, 150, 151, 151, 152, 151, 150, 149, 150, 150, 150, 150, 149, 149, 149, 
    148, 148, 148, 149, 149, 149, 149, 148, 148, 148, 147, 147, 147, 147, 147, 147, 147, 146, 146, 145, 146, 146, 146, 146, 146, 146]

dark_gray = [130, 132, 133, 134, 136, 137, 138, 137, 138, 139, 138, 137, 139, 139, 138, 137, 136, 137, 136, 135, 135, 135, 135, 135, 135, 
    134, 134, 134, 133, 133, 133, 133, 133, 133, 133, 132, 132, 132, 132, 131, 131, 131, 131, 131, 131, 132, 132, 132, 132, 132, 133]

light_gray = [128, 129, 130, 131, 132, 133, 134, 134, 135, 136, 138, 139, 139, 138, 139, 140, 140, 140, 139, 140, 141, 142, 143, 143, 
    144, 144, 143, 142, 142, 142, 142, 143, 143, 144, 143, 144, 144, 144, 144, 145, 145, 145, 145, 146, 146, 145, 145, 145, 145, 145, 145]

if __name__ == "__main__":
    # Look at periods of X seconds, to determine the trend for each period
        # The lower X, the more precise, but also more calculations during simulation
    last_x_idx = 1
    last_x_time = 10
    last_x = last_x_time*last_x_idx

    last_x_black = []
    last_x_darkgray = []
    last_x_lightgray = []

    x_values = []
    
    # Look over our times
        # This is okay for now, since all lists have the same indexes
    for i in range(len(time)):
        if time[i] > last_x: # Hold on till we have enough measurements for a given period

            # Loop backwards till we have all the measurements we want to account for
            start_index = i-1 # Start at the one before
            cur_time = last_x_time # Current time will always be 10, decreased as we look at out previous measurements
            black_diff = 0
            lightgray_diff = 0
            darkgray_diff = 0
            while cur_time > 0:
                if start_index > 0:
                    # Add to the total difference over a given period
                    black_diff += black[start_index] - black[start_index-1]
                    darkgray_diff += dark_gray[start_index] - dark_gray[start_index-1]
                    lightgray_diff += light_gray[start_index] - light_gray[start_index-1]

                    cur_time -= time[start_index] - time[start_index-1]
                    start_index -= 1
                else: # We have reached the start of the list, break out at this point
                    break

            # Add the calculated difference to a list
            last_x_black.append(black_diff)
            last_x_darkgray.append(darkgray_diff)
            last_x_lightgray.append(lightgray_diff)

            # x values, used for plotting
            x_values.append(last_x)

            # Update last_x, so that we check our next time period
            last_x_idx += 1
            last_x = last_x_time*last_x_idx

    print(x_values)
    print(last_x_black)
    print(last_x_darkgray)
    print(last_x_lightgray)

    # DEBUGGING
        # Find the point of interest by checking for the first negative trend
            # This will be a lap-press in the simulation
    start_index = 0
    for i in range(len(x_values)):

        if last_x_black[i] < 0:
            start_index = i
            break;

        if last_x_darkgray[i] < 0:
            start_index = i
            break;

        if last_x_lightgray[i] < 0:
            start_index = i
            break;
    print("\nWe start at: " + str(start_index))


        # Calculate the average of the trends, to determine wether the heartrate is
            # Increasing, Decreasing, or doing nothing
    black_total = 0
    dg_total = 0
    lg_total = 0
    for i in range(start_index, len(x_values)-1):
        black_total += last_x_black[i]
        dg_total += last_x_darkgray[i]
        lg_total += last_x_lightgray[i]
    print(black_total)
    print(dg_total)
    print(lg_total)



    # PLOTTING
    # PLOT 1
    # Smoothing
    x_new = np.linspace(time[0], time[len(time)-1], 300)
    black_bs_line = make_interp_spline(np.array(time), np.array(black))
    black_y_new = black_bs_line(x_new)
    dg_bs_line = make_interp_spline(np.array(time), np.array(dark_gray))
    dg_y_new = dg_bs_line(x_new)
    lg_bs_line = make_interp_spline(np.array(time), np.array(light_gray))
    lg_y_new = lg_bs_line(x_new)

    plt.figure()
    plt.xlabel("Time")
    plt.ylabel("Heartrates")
    plt.plot(x_new, black_y_new, 'black', x_new, dg_y_new, 'dimgray', x_new, lg_y_new, 'lightgray')

    # PLOT 2
    # Smoothing
    '''
    x_new = np.linspace(x_values[0], x_values[len(x_values)-1], 300)
    black_bs_line = make_interp_spline(np.array(x_values), np.array(last_x_black))
    black_y_new = black_bs_line(x_new)
    dg_bs_line = make_interp_spline(np.array(x_values), np.array(last_x_darkgray))
    dg_y_new = dg_bs_line(x_new)
    lg_bs_line = make_interp_spline(np.array(x_values), np.array(last_x_lightgray))
    lg_y_new = lg_bs_line(x_new)
    '''

    plt.figure()
    # Line accross 0    
    plt.axhline(y=0, color='g', linestyle='-')

    plt.xlabel("Time")
    plt.ylabel("Difference")
    plt.plot(x_values, last_x_black, 'black', x_values, last_x_darkgray, 'dimgray', x_values, last_x_lightgray, 'lightgray')
    
    plt.show()
