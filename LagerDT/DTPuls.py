import pandas
from sklearn import tree
from sklearn.tree import DecisionTreeClassifier
import pydotplus
import matplotlib.pyplot as plt
import matplotlib.image as pltimg
from sklearn2pmml.pipeline import PMMLPipeline
from sklearn2pmml import sklearn2pmml
from sklearn.tree import export_text

df = pandas.read_csv("pulsTre/heartrates.csv", ",")

# d = {'svart': 0, 'moerkegraa': 1, 'lysegraa': 2}
# df['gruppe'] = df['gruppe'].map(d)

# features = ['diff10', 'diff20', 'diff30', 'diff40', 'diff50', 'diff60', 'diff70', 'diff80', 'diff90']
# diff10,diff20,diff30,diff40,diff50,diff60,diff70,diff80,diff90,gruppe
features = ['0', '1', '2', '3', '4', '5', '6', '7', '8']
X = df[features]
y = df['gruppe']

dtree = DecisionTreeClassifier()
dtree = dtree.fit(X, y)

data = tree.export_graphviz(dtree, out_file=None, feature_names=features)
graph = pydotplus.graph_from_dot_data(data)
graph.write_png('DTPulsBilde.png')

img=pltimg.imread('DTPulsBilde.png')
imgplot = plt.imshow(img)
# plt.show()

pipeline = PMMLPipeline([
	("classifier", dtree)
])
pipeline.fit(X, y)

sklearn2pmml(pipeline, "DTPuls.pmml", with_repr = True)

r = export_text(dtree, features, show_weights=True)
# r = export_text(dtree, feature_names=features["feature_names"], show_weights=True)
print(r)

fil = open("DTPulsTekst.txt", "x")
fil.write(r)
fil.close()