import matplotlib.pyplot as plt
import numpy as np
from sklearn import linear_model
import os

SIZE = 24

plt.rc('font', size=SIZE)          # controls default text sizes
plt.rc('axes', titlesize=SIZE)     # fontsize of the axes title
plt.rc('axes', labelsize=SIZE)    # fontsize of the x and y labels
plt.rc('xtick', labelsize=SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=SIZE-4)    # legend fontsize
plt.rc('figure', titlesize=SIZE)  # fontsize of the figure title

# Indexes are seconds, common for all, can also be different between the measurements
    # We probably want the total to be that same though?
distance = [0, 23, 46, 69, 92, 115, 138, 161, 184, 207, 230, 253, 276, 299, 322, 345, 368, 391, 414, 
    437, 460, 483, 506, 529, 552, 575, 598, 621, 644, 667, 690, 713, 736, 759, 782, 805]

black = [151, 151, 152, 151, 150, 149, 150, 150, 150, 150, 149, 149, 149, 
    148, 148, 148, 149, 149, 149, 149, 148, 148, 148, 147, 147, 147, 147, 147, 147, 147, 146, 146, 145, 146, 146, 146]

dark_gray = [139, 139, 138, 137, 136, 137, 136, 135, 135, 135, 135, 135, 135, 
    134, 134, 134, 133, 133, 133, 133, 133, 133, 133, 132, 132, 132, 132, 131, 131, 131, 131, 131, 131, 132, 132, 132]

light_gray = [139, 138, 139, 140, 140, 140, 139, 140, 141, 142, 143, 143, 
    144, 144, 143, 142, 142, 142, 142, 143, 143, 144, 143, 144, 144, 144, 144, 145, 145, 145, 145, 146, 146, 145, 145, 145]

if __name__ == "__main__":
    # Look at periods of X seconds, to determine the trend for each period
        # The lower X, the more precise, but also more calculations during simulation
    last_x_idx = 1
    last_x_dist = 50
    last_x = last_x_dist*last_x_idx

    last_x_black = []
    last_x_darkgray = []
    last_x_lightgray = []

    dist_period = []
    
    # Look over our times
        # This is okay for now, since all lists have the same indexes
    for i in range(len(distance)):
        if distance[i] > last_x: # Hold on till we have enough measurements for a given period

            # Loop backwards till we have all the measurements we want to account for
            start_index = i-1 # Start at the one before
            cur_dist = last_x_dist # Current time will always be 10, decreased as we look at out previous measurements
            black_diff = 0
            lightgray_diff = 0
            darkgray_diff = 0
            while cur_dist > 0:
                if start_index > 0:
                    # Add to the total difference over a given period
                    black_diff += black[start_index] - black[start_index-1]
                    darkgray_diff += dark_gray[start_index] - dark_gray[start_index-1]
                    lightgray_diff += light_gray[start_index] - light_gray[start_index-1]

                    cur_dist -= distance[start_index] - distance[start_index-1]
                    start_index -= 1
                else: # We have reached the start of the list, break out at this point
                    break

            # Add the calculated difference to a list
            last_x_black.append(black_diff)
            last_x_darkgray.append(darkgray_diff)
            last_x_lightgray.append(lightgray_diff)

            # x values, used for plotting
            dist_period.append(last_x)

            # Update last_x, so that we check our next time period
            last_x_idx += 1
            last_x = last_x_dist*last_x_idx

    print(dist_period)
    print(last_x_black)
    print(last_x_darkgray)
    print(last_x_lightgray)
    print("\n")

    # Calculate the average of the trends, to determine wether the heartrate is
        # Increasing, Decreasing, or doing nothing
    black_total = 0
    dg_total = 0
    lg_total = 0

    black_total_diff = []
    black_diff = []
    dg_total_diff = []
    dg_diff = []
    lg_total_diff = []
    lg_diff = []

    for i in range(0, len(dist_period)):
        black_total += last_x_black[i]
        black_total_diff.append(black_total)
        black_diff.append(last_x_black[i])

        dg_total += last_x_darkgray[i]
        dg_total_diff.append(dg_total)
        dg_diff.append(last_x_darkgray[i])

        lg_total += last_x_lightgray[i]
        lg_total_diff.append(lg_total)
        lg_diff.append(last_x_lightgray[i])
    
    print("BLACK:")
    print(black_diff)
    print(black_total_diff)
    print("\n")
    print("DARK GRAY:")
    print(dg_diff)
    print(dg_total_diff)
    print("\n")
    print("LIGHT GRAY")
    print(lg_diff)
    print(lg_total_diff)

    write_to_json = []

    # LINEAR REGRESSION ANALYSIS
    print("\nLinear Regression Analysis")
    print("Black regression:")
    black_regr = linear_model.LinearRegression()

    regr_x = np.array(dist_period).reshape(-1, 1)
    regr_y = np.array(black_total_diff).reshape(-1, 1)
    black_regr.fit(regr_x, regr_y)

    print(black_regr.intercept_[0])
    print(black_regr.coef_[0][0])
    write_to_json.append([black_regr.intercept_[0], black_regr.coef_[0][0]])

    print("\nDark Gray regression:")
    dg_regr = linear_model.LinearRegression()

    regr_x = np.array(dist_period).reshape(-1, 1)
    regr_y = np.array(dg_total_diff).reshape(-1, 1)
    dg_regr.fit(regr_x, regr_y)

    print(dg_regr.intercept_[0])
    print(dg_regr.coef_[0][0])
    write_to_json.append([dg_regr.intercept_[0], dg_regr.coef_[0][0]])

    print("\nLight Gray regression:")
    lg_regr = linear_model.LinearRegression()

    regr_x = np.array(dist_period).reshape(-1, 1)
    regr_y = np.array(lg_total_diff).reshape(-1, 1)
    lg_regr.fit(regr_x, regr_y)

    print(lg_regr.intercept_[0])
    print(lg_regr.coef_[0][0])
    write_to_json.append([lg_regr.intercept_[0], lg_regr.coef_[0][0]])

    # WRITE THE ANALYSE.JSON FILE HERE AND UPDATE THE PROJECT
        # REBUILD
    def bygg_fil(prosjekt_location, project_name, key, text_to_write):
        # Change to directory
        dir = project_location + project_name + "/resources/data"
        os.chdir(dir)

        # Write to file, overwrites the one that is there
        file = open("analyse.json", "w")
        file.write(text_to_write)
        file.close()

        os.system(
            "monkeyc -y " + key + " -f " + project_location+project_name+"/monkey.jungle " + "-o " + project_location+project_name+"/bin/"+project_name+".prg"
        )
        
    project_location = "C:/Users/magnu/eclipse-workspace/"
    project_name = "SeveralDataFields"
    key = "C:/Users/magnu/keys/developer_key"
    #bygg_fil(project_location, project_name, key, string(write_to_json))


    result = True
    if result:
        svart_resultat = [1, 2, 2, -1, -3, -6, -6, -4, -4, -1, -1, 0, 3, 1, 1, 1]
        dg_result = [0, -3, -5, -7, -9, -11, -10, -10, -10, -8, -10, -9, -11, -11, -7, -10]
        lg_result = [3, 4, 5, 7, 7, 8, 9, 10, 11, 12, 12, 13, 12, 13, 13, 13]

        semi_result = [2, 3, 5, 7, 7, 7, 8, 10, 10, 11]
        semi_dist = dist_period[0:len(semi_result)]

        plt.figure()
        plt.xlabel("Avstand [m]")
        plt.ylabel("Total differanse [hjertefrekvens]")

        # Result of DG group
        '''
        result_regr = linear_model.LinearRegression()
        regr_x = np.array(dist_period).reshape(-1, 1)
        regr_y = np.array(svart_resultat).reshape(-1, 1)
        result_regr.fit(regr_x, regr_y)
        y_pred = result_regr.predict(regr_x.reshape(-1, 1))
        plt.plot(dist_period, y_pred, color='red')
        '''
        # Result of DG group
        '''
        result_regr = linear_model.LinearRegression()
        regr_x = np.array(dist_period).reshape(-1, 1)
        regr_y = np.array(dg_result).reshape(-1, 1)
        result_regr.fit(regr_x, regr_y)
        y_pred = result_regr.predict(regr_x.reshape(-1, 1))
        plt.plot(dist_period, y_pred, color='red')
        '''
        # Result of LG group
        '''
        result_regr = linear_model.LinearRegression()
        regr_x = np.array(dist_period).reshape(-1, 1)
        regr_y = np.array(lg_result).reshape(-1, 1)
        result_regr.fit(regr_x, regr_y)
        y_pred = result_regr.predict(regr_x.reshape(-1, 1))
        plt.plot(dist_period, y_pred, color='red')
        

        y_pred = black_regr.predict(regr_x.reshape(-1, 1))
        plt.plot(dist_period, y_pred, color='black')
        y_pred = dg_regr.predict(regr_x.reshape(-1, 1))
        plt.plot(dist_period, y_pred, color='dimgray')
        y_pred = lg_regr.predict(regr_x.reshape(-1, 1))
        plt.plot(dist_period, y_pred, color='lightgray')
        '''

        plt.plot(semi_dist, semi_result, color='red', marker='o', linestyle='dashed')
        plt.plot(dist_period, black_total_diff, color='black', marker='o', linestyle='dashed')
        plt.plot(dist_period, dg_total_diff, color='dimgray', marker='o', linestyle='dashed')
        plt.plot(dist_period, lg_total_diff, color='lightgray', marker='o', linestyle='dashed')
        plt.legend(["Press Trend", "Normal", "Safe", "Press"])

        #plt.plot(dist_period, lg_result, color='red', marker='o', linestyle='none')
        #plt.plot(dist_period, black_total_diff, color='black', marker='o', linestyle='none')
        #plt.plot(dist_period, dg_total_diff, color='dimgray', marker='o', linestyle='none')
        #plt.plot(dist_period, lg_total_diff, color='lightgray', marker='o', linestyle='none')
        #plt.legend(["Press Resultat", "Normal", "Safe", "Press"])
    else:
        # PLOTTING
        # PLOT 1 -> GENERAL
        
        #plt.figure()
        #plt.xlabel("Avstand [m]")
        #plt.ylabel("Hjertefrekvens [per min]")
        #plt.plot(distance, black, 'black', distance, dark_gray, 'dimgray', distance, light_gray, 'lightgray')
        #plt.legend(["Normal", "Safe", "Press"])
        
        
        # PLOT 2 -> BLACK, DG, LG DIFFERENCE OVER TIME PERIODS
        plt.figure()
        plt.xlabel("Avstand [m]")
        plt.ylabel("Differanse [hjertefrekvens]")
        plt.plot(dist_period, black_diff, color='black', marker='o', linestyle='dashed')
        plt.plot(dist_period, dg_diff, color='dimgray', marker='o', linestyle='dashed')
        plt.plot(dist_period, lg_diff, color='lightgray', marker='o', linestyle='dashed')
        plt.legend(["Normal", "Safe", "Press"])
        plt.axhline(y=0, color='blue', linestyle='-')

        # PLOT 3 -> BLACK, DG, LG TOTAL DIFFERENCE OVER TIME PERIODS
        plt.figure()
        plt.xlabel("Avstand [m]")
        plt.ylabel("Total differanse [hjertefrekvens]")
        plt.plot(dist_period, black_total_diff, color='black', marker='o', linestyle='dashed')
        plt.plot(dist_period, dg_total_diff, color='dimgray', marker='o', linestyle='dashed')
        plt.plot(dist_period, lg_total_diff, color='lightgray', marker='o', linestyle='dashed')
        plt.legend(["Normal", "Safe", "Press"])

        # PLOT 4 -> BLACK, DG, LG TOTAL DIFFERENCE OVER TIME PERIODS WITH REGRESSION
        plt.figure()
        plt.xlabel("Avstand [m]")
        plt.ylabel("Total differanse [hjertefrekvens]")

        y_pred = black_regr.predict(regr_x.reshape(-1, 1))
        plt.plot(dist_period, y_pred, color='black')
        y_pred = dg_regr.predict(regr_x.reshape(-1, 1))
        plt.plot(dist_period, y_pred, color='dimgray')
        y_pred = lg_regr.predict(regr_x.reshape(-1, 1))
        plt.plot(dist_period, y_pred, color='lightgray')
        plt.legend(["Normal", "Safe", "Press"])

        plt.plot(dist_period, black_total_diff, color='black', marker='o', linestyle='none')
        plt.plot(dist_period, dg_total_diff, color='dimgray', marker='o', linestyle='none')
        plt.plot(dist_period, lg_total_diff, color='lightgray', marker='o', linestyle='none')

        
        # PLOT 5, 6, 7 -> Regression analysis
        '''
        # BLACK
        plt.figure()
        plt.xlabel("Time")
        plt.ylabel("Total difference")
        plt.plot(dist_period, black_total_diff, color='black', marker='o', linestyle='none')
        y_pred = black_regr.predict(regr_x.reshape(-1, 1))
        plt.plot(dist_period, y_pred, color='blue')

        # DARK GRAY
        plt.figure()
        plt.xlabel("Time")
        plt.ylabel("Total difference")
        plt.plot(dist_period, dg_total_diff, color='dimgray', marker='o', linestyle='none')
        y_pred = dg_regr.predict(regr_x.reshape(-1, 1))
        plt.plot(dist_period, y_pred, color='blue')

        # LIGHT GRAY
        plt.figure()
        plt.xlabel("Time")
        plt.ylabel("Total difference")
        plt.plot(dist_period, lg_total_diff, color='lightgray', marker='o', linestyle='none')
        y_pred = lg_regr.predict(regr_x.reshape(-1, 1))
        plt.plot(dist_period, y_pred, color='blue')
        '''

    plt.rcParams.update({'font.size': 22})
    plt.show()