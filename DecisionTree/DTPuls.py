import pandas
from sklearn import tree
from sklearn.tree import DecisionTreeClassifier
import pydotplus
import matplotlib.pyplot as pyplot
import matplotlib.image as image
from sklearn2pmml.pipeline import PMMLPipeline
from sklearn2pmml import sklearn2pmml
from sklearn.tree import export_text

# Med tid
# df = pandas.read_csv("heartrates.csv", ",")
# Med distanse
df = pandas.read_csv("hrdistanse.csv", ", ", engine="python")

simdata = open("hrdistanse.csv", "r")
firstLine = simdata.readline().rstrip().split(", ")
simdata.close()
features = firstLine[:-1]
# features = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15']
category = firstLine[-1]
# category = "gruppe"

# d = {'svart': 0, 'moerkegraa': 1, 'lysegraa': 2}
# df['gruppe'] = df['gruppe'].map(d)

X = df[features]
y = df[category]

decisiontree = DecisionTreeClassifier()
decisiontree = decisiontree.fit(X, y)

# Bilde
innhold = tree.export_graphviz(decisiontree, feature_names=features)
graf = pydotplus.graph_from_dot_data(innhold)
graf.write_png('avstand/DTPulsBildeAvstand.png')
picture = image.imread('avstand/DTPulsBildeAvstand.png')
pictureplot = pyplot.imshow(picture)
# pyplot.show()

# PMML - skal ikke brukes
# pipeline = PMMLPipeline([
# 	("classifier", decisiontree)
# ])
# pipeline.fit(X, y)
# sklearn2pmml(pipeline, "avstand/DTPulsAvstand.pmml", with_repr = True)

# Tekst
text = export_text(decisiontree, feature_names=features, show_weights=True)
# print(text)
fil = open("avstand/DTPulsTekstAvstand.txt", "w")
fil.write(text)
fil.close()