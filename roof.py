#!/usr/bin/env python
import matplotlib.pyplot as plt
import numpy as np

def label_line(line, label, x, y, color='0.5', size=12):
    """Add a label to a line, at the proper angle.

    Arguments
    ---------
    line : matplotlib.lines.Line2D object,
    label : str
    x : float
        x-position to place center of text (in data coordinated
    y : float
        y-position to place center of text (in data coordinates)
    color : str
    size : float
    """
    xdata, ydata = line.get_data()
    x1 = xdata[0]
    x2 = xdata[-1]
    y1 = ydata[0]
    y2 = ydata[-1]

    ax = line.axes
    text = ax.annotate(label, xy=(x, y), xytext=(-10, 0),
                       textcoords='offset points',
                       size=size, color=color,
                       horizontalalignment='left',
                       verticalalignment='bottom')

    sp1 = ax.transData.transform_point((x1, y1))
    sp2 = ax.transData.transform_point((x2, y2))

    rise = (sp2[1] - sp1[1])
    run = (sp2[0] - sp1[0])

    slope_degrees = np.degrees(np.arctan2(rise, run))
    text.set_rotation(slope_degrees)
    return text

def main():
    plt.xlabel('Arithmetic intensity (FLOP/byte)',fontsize=20)
    plt.ylabel('Performance (GFLOPS)',fontsize=20)
    plt.xticks(fontsize=14)
    plt.yticks(fontsize=14)
    plt.loglog()

    xmin = 1.0e-2
    xmax = 1000
    ymin = 1.0e-2
    ymax = 1.0e3

    # ridge
    # 2nd x point is where label is placed
    x_bw = [xmin, 1.0e-3, 10]

    # Flat mode
    
    # DRAM
    BW = 15.2
    y_bw = [BW * x_bw[0], BW * x_bw[1], BW * x_bw[2]]
    plt.plot(x_bw, y_bw, color='r', linestyle='-', label='_DRAM: 15.7 GB/s')

    # L3
    BW = 27.8
    y_bw = [BW * x_bw[0], BW * x_bw[1], BW * x_bw[2]]
    plt.plot(x_bw, y_bw, color='y', linestyle='-', label='_L3: 26.5 GB/s')

    # L2
    BW = 228.7
    y_bw = [BW * x_bw[0], BW * x_bw[1], BW * x_bw[2]]
    plt.plot(x_bw, y_bw, color='g', linestyle='-', label='_L2: 226.1 GB/s')

    # L1
    BW = 362.0
    y_bw = [BW * x_bw[0], BW * x_bw[1], BW * x_bw[2]]
    plt.plot(x_bw, y_bw, color='b', linestyle='-', label='_L1: 362.2 GB/s')

    # roof
    x_compute = [1.0e-2,15,xmax]

    # Scalar add peak
    y_compute = [7.4, 7.4, 7.4]
    plt.plot(x_compute, y_compute, color='r', linestyle='-',
             label='_Scalar add: 7.4 GF/s')

    # DP Vector add peak
    y_compute = [52.6, 52.6, 52.6]
    plt.plot(x_compute, y_compute, color='y', linestyle='-',
             label='_DP vector add: 52.6 GF/s')

    # DP Vector FMA peak
    y_compute = [105.2, 105.2, 105.2]
    plt.plot(x_compute, y_compute, color='g', linestyle='-',
             label='_DP vector FMA: 105.2 GF/s')#, SP vector add')

#    # SP Vector add peak
#    y_compute = [105.2, 105.2, 105.2]
#    plt.plot(x_compute, y_compute, color='c', linestyle='-',
#             label='SP vector add')

    # SP Vector FMA peak
    y_compute = [210.3, 210.3, 210.3]
    plt.plot(x_compute, y_compute, color='b', linestyle='-',
             label='_SP vector FMA: 210.3 GF/s')

    # plot the labels
    lines = plt.gca().get_lines()
    for line in lines:
        label_line(line, line.get_label(),
                   line.get_xdata()[1], line.get_ydata()[1])

    # SpMV
    AI = 0.10
    GFS = 1.55
    plt.plot(AI,GFS,'o',ms=10,color='r',label='SpMV')
    plt.plot([AI,AI], [ymin,ymax], color='k', linestyle='--', lw=0.2)
    plt.plot([xmin,xmax], [GFS,GFS], color='k', linestyle='--', lw=0.2)

    # SYMGS Forward
    AI = 0.1
    GFS = 2.1
    plt.plot(AI,GFS,'o',ms=10,color='g',label='GS Forward')
    plt.plot([AI,AI], [ymin,ymax], color='k', linestyle='--', lw=0.2)
    plt.plot([xmin,xmax], [GFS,GFS], color='k', linestyle='--', lw=0.2)

    # SYMGS Backward
    AI = 0.1
    GFS = 1.752
    plt.plot(AI,GFS,'o',ms=10,color='b',label='GS Backward')
    plt.plot([AI,AI], [ymin,ymax], color='k', linestyle='--', lw=0.2)
    plt.plot([xmin,xmax], [GFS,GFS], color='k', linestyle='--', lw=0.2)


# miniapp 1, the update loop, flat mode MCDRAM

#    # fortran
#    AI = 0.433
#    GFS = 86
#    plt.plot(AI,GFS,'*',ms=10,label='Fortran')
#    plt.plot([AI,AI], [ymin,ymax], color='k', linestyle='--', lw=0.2)
#    plt.plot([xmin,xmax], [GFS,GFS], color='k', linestyle='--', lw=0.2)
#
#    # intrinsic
#    AI = 0.263
#    GFS = 365
#    plt.plot(AI,GFS,'o',ms=5,label='Intrinsic')
#    plt.plot([AI,AI], [ymin,ymax], color='k', linestyle='--', lw=0.2)
#    plt.plot([xmin,xmax], [GFS,GFS], color='k', linestyle='--', lw=0.2)

# miniapp 2
        
#    # omp parallel with atomics
#    AI = 0.046
#    GFS = 17.5 # GF/s higher than color, but slower!
#    plt.plot(AI,GFS,'*',ms=10,label='color: 17.5 GF/s')
#    plt.plot([AI,AI], [ymin,ymax], color='k', linestyle='--', lw=0.2)
#    plt.plot([xmin,xmax], [GFS,GFS], color='k', linestyle='--', lw=0.2)

#    # omp parallel with coloring, no atomics
#    AI = 0.064
#    GFS = 19.7
#    plt.plot(AI,GFS,'*',ms=10,label='run time')
#    # 375 x 0.064 = 24
#    plt.plot([AI,AI], [ymin,ymax], color='k', linestyle='--', lw=0.2)
#    plt.plot([xmin,xmax], [GFS,GFS], color='k', linestyle='--', lw=0.2)
#
#    # omp parallel with coloring, hardwired geometry
#    AI = 0.059
#    GFS = 15.4
#    plt.plot(AI,GFS,'o',ms=5,label='compile time')
#    plt.plot([AI,AI], [ymin,ymax], color='k', linestyle='--', lw=0.2)
#    plt.plot([xmin,xmax], [GFS,GFS], color='k', linestyle='--', lw=0.2)

    plt.legend(loc='lower right')
    plt.show()

if __name__ == "__main__":
    main()
