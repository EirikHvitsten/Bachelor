import pandas
from sklearn import tree
from sklearn.tree import DecisionTreeClassifier
import pydotplus
import matplotlib.pyplot as plt
import matplotlib.image as pltimg
# import graphviz

df = pandas.read_csv("heartrates.csv", ",")

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
# Lager bilde
# graph.write_png('pulsTre.png')
# img=pltimg.imread('pulsTre.png')
# imgplot = plt.imshow(img)

# plt.show()

print("Alle her skal være svart")
svar = dtree.predict([[0, -2, -5, -6, 2, 2, 2, 3, -2]])
print(svar)
svar = dtree.predict([[-2, 0, 0, 2, 1, 0, -2, 0, -2]])
print(svar)
svar = dtree.predict([[2, 0, -1, 0, 0, -1, 0, 0, 0]])
print(svar)
svar = dtree.predict([[-4, -6, 1, 1, -4, -4, 4, 5, 4]])
print(svar)
svar = dtree.predict([[-1, -5, -2, 3, -1, -1, 0, 1, 0]])
print(svar)
svar = dtree.predict([[2, -3, -1, -1, 0, -1, -1, -2, 1]])
print(svar)
svar = dtree.predict([[4, 1, 1, -1, 1, -1, -1, 1, 2]])
print(svar)
svar = dtree.predict([[3, 3, 0, 0, 1, -2, -2, -2, 1]])
print(svar)

print("\nAlle her skal være mørkegrå")
svar = dtree.predict([[-1, -2, 1, 0, 1, 2, -5, -2, 1]])
print(svar)
svar = dtree.predict([[-2, -4, -6, -2, -1, -2, -3, 1, -2]])
print(svar)
svar = dtree.predict([[0, -1, -5, -3, 4, 1, -2, -1, -6]])
print(svar)
svar = dtree.predict([[-1, 0, -2, -2, -1, -2, 1, 1, 0]])
print(svar)
svar = dtree.predict([[-3, 2, -1, -3, 0, -1, -2, 1, 2]])
print(svar)
svar = dtree.predict([[1, 0, 1, 0, -1, -2, -2, 0, 0]])
print(svar)
svar = dtree.predict([[1, -2, 1, -1, 1, -2, 1, 1, 0]])
print(svar)
