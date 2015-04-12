###############################################################################
### Copyright FRC Team 1736 RobotCasserole 2015 All rights Reserved
###############################################################################
# gui_main.py - Main entry point for robot position visualization GUI.
#               Recieves serial commands from the RoboSim unit
#               representing the current state of the robot and updates
#               a simple animation of the results.
#
# Requires Python 2.7.6 or later (not tested on 3.x python) 
#
# Change History - 
#     Chris G - Apr 12 2015 - Created
#
###############################################################################

import os, sys
import Tkinter as tk
import time

#Global constants
WORLD_X_BOUND = 400
WORLD_Y_BOUND = 400

#Class for robot to be drawn on the screen
class Robot(object):
    def __init__(self, canvas, *args, **kwargs):
        self.canvas = canvas
        self.id = canvas.create_rectangle(20, 260, 120, 360, outline = 'black', fill = 'blue') #robot is a rectangle
        self.x_pose = 5 #current x position in world
        self.y_pose = 0 #current y position in world
        self.theta_pose = 0 #current rotation in degrees relative to 

    #move robot to new x/y/theta position
    def move_to_pos(self, new_x, new_y):
        x1, y1, x2, y2 = self.canvas.bbox(self.id)
        if x2 > 400: self.vx = -5
        if x1 < 0: self.vx = 5
        self.canvas.move(self.id, self.vx, self.vy)

class App(object):
     def __init__(self, master, **kwargs):
        self.master = master             
        self.canvas = tk.Canvas(self.master, width = 400, height = 400)
        self.canvas.pack()
        self.robots = [
            Robot(self.canvas)
            ]
        self.canvas.pack()
        self.master.after(0, self.animation)

     def animation(self):
         for alien in self.aliens:
             alien.move()
         self.master.after(12, self.animation)

root = tk.Tk()
app = App(root)
root.mainloop()
