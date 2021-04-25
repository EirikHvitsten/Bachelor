import pandas
from sklearn import tree
from sklearn.tree import DecisionTreeClassifier
import pydotplus
import matplotlib.pyplot as pyplot
import matplotlib.image as image
from sklearn2pmml.pipeline import PMMLPipeline
from sklearn2pmml import sklearn2pmml
from sklearn.tree import export_text
import math

def makeThrees(n):
    df = pandas.read_csv("hrdistanse.csv", ", ", engine="python")

    simdata = open("hrdistanse.csv", "r")
    firstLine = simdata.readline().rstrip().split(", ")
    simdata.close()

    lenght = len(firstLine) - 1
    for k in range(1, n+1):
        print(k)
        amount = round(lenght / n * k)
        features = firstLine[:amount]
        print(features)
        category = firstLine[-1]
        # print(category)
        
        X = df[features]
        y = df[category]

        decisiontree = DecisionTreeClassifier()
        decisiontree = decisiontree.fit(X, y)

        # Bilde
        innhold = tree.export_graphviz(decisiontree, feature_names=features)
        graf = pydotplus.graph_from_dot_data(innhold)
        graf.write_png("threetrees/DTPulsBildeAvstand" + str(k) + ".png")
        picture = image.imread("threetrees/DTPulsBildeAvstand" + str(k) + ".png")
        # pyplot.imshow(picture)
        # pyplot.show()

        # Tekst
        text = export_text(decisiontree, feature_names=features, show_weights=True)
        # print(text)
        fil = open("threetrees/DTPulsTekstAvstand" + str(k) + ".txt", "w")
        fil.write(text)
        fil.close()

if __name__ == "__main__":
    makeThrees(3)