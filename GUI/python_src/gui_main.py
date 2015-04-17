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
import time, random

#Global constants
WORLD_X_BOUND = 400
WORLD_Y_BOUND = 400
ROBOT_X_WIDTH = 50
ROBOT_Y_WIDTH = 50

#Class for robot to be drawn on the screen
class Robot(object):
    def __init__(self, canvas, *args, **kwargs):
        self.canvas = canvas
        self.x_pose = int(WORLD_X_BOUND/2) #current x position in world
        self.y_pose = int(WORLD_Y_BOUND/2)  #current y position in world
        self.theta_pose = 0 #current rotation in degrees relative to 
        self.id = canvas.create_rectangle(int(self.x_pose - ROBOT_X_WIDTH/2), int(self.y_pose - ROBOT_Y_WIDTH/2), int(self.x_pose + ROBOT_X_WIDTH/2), int(self.y_pose + ROBOT_Y_WIDTH), outline = 'black', fill = 'blue') #robot is a rectangle

    #move robot to new x/y/theta position
    def move_to_pos(self, new_x, new_y):
        x1, y1, x2, y2 = self.canvas.bbox(self.id)
        
        #bound the new position within the world        
        if new_x < 0:
            new_x = 0
        if new_x > WORLD_X_BOUND:
            new_x = WORLD_X_BOUND
        if new_y < 0:
            new_y = 0
        if new_y > WORLD_Y_BOUND:
            new_y = WORLD_Y_BOUND

        move_delta_x = new_x - self.x_pose
        move_delta_y = new_y - self.y_pose
        
        print("DX= " + str(move_delta_x) + " DY= " + str(move_delta_y))

        self.canvas.move(self.id, move_delta_x, move_delta_y)
        self.x_pose = new_x
        self.y_pose = new_y


class App(object):
     def __init__(self, master, **kwargs):
        self.master = master             
        self.canvas = tk.Canvas(self.master, width = WORLD_X_BOUND, height = WORLD_Y_BOUND)
        self.canvas.pack()
        self.robots = [
            Robot(self.canvas)
            ]
        self.canvas.pack()
        self.master.after(0, self.animation)

        self.temp_x_pos = 200
        self.temp_y_pos = 200

     def animation(self):
               
        self.temp_x_pos = self.temp_x_pos + 1
        self.temp_y_pos = self.temp_y_pos + 1
        
        for robot in self.robots:
            robot.move_to_pos(self.temp_x_pos, self.temp_y_pos)
        self.master.after(50, self.animation)

root = tk.Tk()
app = App(root)
root.mainloop()
