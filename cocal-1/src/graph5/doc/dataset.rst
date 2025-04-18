
Dataset
===========

The Dataset class is used to contain the data points and drawing style
of a 'set' of data.  It also keeps track of which axis on the graph that
the data is to be mapped to.

A data point consists of an x value, a y value, and a weight value.
The weight value is used to distinguish between different drawing styles.
For example, a data set of

    x = [1, 2, 3]
    y = [2, 3, 4]
    wt = [0, 0, 1]

will have the first two points drawn in the first style, the third point
drawn in the second style.

The x and y values are stored as numpy arrays for faster processing.

The Dataset class also has a popup dialog that can be used to dynamically
change the style attributes of the dataset.

Constructor
-----------

class Dataset( x = None, y = None, name = "")

    x and y are lists of numbers representing the x axis and y axis values.
    

Class Attributes:
-----------------

	dataset. **name**
            Same as dataset.label

	dataset. **hidden**
            True if dataset is not to be drawn in graph.  Default is False

	dataset. **label**
            Label to use in graph legend for the dataset.

	dataset. **xaxis**
            The id of the xaxis to map the data on

	dataset. **yaxis**
            The id of the yaxis to map the data on

	dataset. **xdata**
            numpy array created from x list

	dataset. **ydata**
            numpy array created from y list

	dataset. **weights**
            numpy array with corresponding weight value for each data point.
            Default is an array of zeros equal to xdata in length

	dataset. **ymin**
            The minimum value in ydata

	dataset. **ymax**
            The maximum value in ydata

	dataset. **xmin**
            The minimum value in xdata

	dataset. **xmax**
            The maximum value in xdata

	dataset. **missingValue**
            Value to designate a 'missing' data point.
            ** Unused **

	dataset. **subsetStart**
           ** Unused **

	dataset. **subsetEnd**
           ** Unused **

	dataset. **userData**
           An user specified list that corresponds to the xdata, ydata arrays.
           That is, we can remember an additional list of data that the developer can
           access at any time.  Typical example is if the index of a data point is known,
           get the userData that goes with this data point.  mydata = dataset.userData[index] 
           The userData list is not used by the graph widget at all, it is
           there just to attach some extra data to the dataset.

	dataset. **styles**
            List of Style objects for drawing the dataset.  There should be one style
            for each unique value in the weights array.

Class Methods:
-----------------

    dataset. **SetData** (x, y, w=[])
	Convert the given list of x and y data values
	to a numpy array, and save.  x and y must be same length.
        The weight list is optional, but if given should be same length as x and y.

    dataset. **SetAxis** (axis)
	Set the axis that this dataset is mapped to.  **axis** is an axis object.  It can be obtained by using the graph.getXAxis() or graph.getYAxis() methods.

    dataset. **SetWeights** (wt)
	List of weight values for each data point.
	The length of wt should match that of xdata and ydata.

    dataset. **SetStyle** (style)
	Set the default style class for the entire dataset

    dataset. **SetWeightStyle** (wt, style):
	Set the style class for points matching a weight value.

    dataset. **ShowDatasetStyleDialog** (graph)
	Show the popup dialog for editing style attributes.

