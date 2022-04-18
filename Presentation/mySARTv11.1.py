# import time 
import copy
import random
import csv
import os
import glob
from psychopy import visual, core, data, event, gui,monitors,logging,info, parallel
import matplotlib.pyplot as plt
from pygame import time
from ctypes import windll
P = windll.inpoutx64
random.seed(2)
mon = monitors.Monitor("testMonitor", width=53.2, distance=65.0)
for mon in monitors.getAllMonitors():
	print(mon, monitors.Monitor(mon).getSizePix())
# 	if mon = "testMonitor":
# 		monitorSize = monitors.Monitor(mon).getSizePix()
screenSize = [1920,1080]#
screenRatio = screenSize[0]/screenSize[1]
# if screenSize == monitorSize:
# 	print("Screen size has been set correctly")

# get a list of stimuli
# test list of stimuli
#filepath = 'generatestimuli/Subj' +str(partInfo[0]) +'/'
filepath = 'generatestimuli/Formal/Subj44/'
extension = 'csv'
os.chdir(filepath)
files = glob.glob('*.{}'.format(extension))
#print(files)
#rawpath = 'C:/Users/EEGExp/Desktop/Project_GMD/pro/'
rawpath = 'F:/Project_GMD/pro/'
#rawpath = 'G:/RUG/Project_GMD/pro/'
os.chdir(rawpath)
def readList(filepath,files,n):
	csv_list=open(filepath + str(files[n]),"r")
	lists=csv.reader(csv_list)
	trialList_i=[]
	for row in lists:
		trialList_i.append(row)
	csv_list.close()
	trialList_i.pop(0)
	return(trialList_i)

## Flickering function
## When the frequency is 50 Hz.
wordDuration = 300
xDuration = 900#+3000
probeLimit = 300
probframes = 3600
flicker_frequency = 12.5#15#
screen_frequency = 50#60
msPerFrame = 1000/screen_frequency

msPerFlicker = 1000/flicker_frequency

ms_onFlicker = msPerFlicker/2
numFrames_flicker = int(msPerFlicker / msPerFrame)
num_onFlicker = int(numFrames_flicker/2)
print(msPerFrame,msPerFlicker,numFrames_flicker,num_onFlicker)

raw_wordFrames = int(wordDuration/msPerFrame)
raw_xFrames = int(xDuration/msPerFrame)

print("How many times the word flickers:"+ str(range(raw_wordFrames))+"\nsquare flickers:"+str(range(0,raw_xFrames)))
#wordFrames = 15-1
#xFrames = 45-1
# window = info.RunTimeInfo(refreshTest = True)
# print(window[["Window"]])
# print(visual.Window.getMsPerFrame(nFrames=60, showVisual=False, msg='', msDelay=0.0))

init_inst = "In this experiment you will view words written in upper- or lower case. Press the 'N' key when the word is written in lower case (e.g., dog).\n\n\
It is important that you respond as quickly as possible.Do not press any button when the word is written in upper case (e.g., TREE).\n\n\
Press the SPACE key when you are ready to start."
prob_inst = "Every now and then, the task will be interrupted with the question of what you were thinking about just now. \
You can answer this question by pressing the number key corresponding to your answer.\n\nPress SPACE key to see example questions."

prob_ques = "What were you thinking about just now?\n\n   1) I was completely focused on the task. \n\n   2) I was evaluating aspects of the task.\n \
(e.g., how I was doing or how long the task was taking) \n\n   3) I was thinking about personal things. \n\n   4) I was distracted by my environment. \n \
 (e.g., sound, temperature, my physical state). \n\n   5) I was daydreaming/ thinking about task-\n       irrelevant things. \n\n   6) \
I was not paying attention, and did not \n     think about anything in particular.\n\n\n Press the key that corresponds to your answer to continue."

prac_inst = "We will start with a few practice trials. Please contact the experimenter \
if you have any remaining questions.\n\nPress the SPACE key to start the practice."

act_task_inst = "The experiment will start now. Do not hesitate to clarify any remaining doubts with the experimenter. Good luck!\n\n\
Press the SPACE key to start the actual task."

def initDataFile(partInfo,path):
	if not os.path.exists('SART_SSVEP_csvData'):
		os.mkdir('SART_SSVEP_csvData')
		#str(partInfo[0]) + "_" + str(partInfo[5]) +
	fileName = "resultSART_" +str(partInfo[0])+ str(partInfo[5]) + ".csv"

	dataFile = open(path + fileName, "w")
	header = ['part_num','part_gender','part_age','part_school_yr',
	'part_normal_vision','exp_initials','block_num','trial_num','word','trialType', 'blockTrial', 'blockNum','raw_crsFrames','raw_wordFrames','raw_xFrames', 'word_trigNo','wordSize_X','wordSize_Y ','str_allKeys','resp_acc','resp_rt','trial_start_time_s','trial_wordTime_s',
	'trial_mask_time_s','trial_end_time_s','trial_feedback_time','trial_crsDuration','trial_wordDuration','trial_maskDuration',
	'trial_maskendDuration','trial_totalDuration']
	dataFile.write(','.join(header) + '\n')
	return dataFile

def part_info_gui():
	info = gui.Dlg(title='SART')
	info.addText('Participant Info')
	info.addField('Part. Number: ')
	info.addField('Part. Gender:', 
		choices=["Please Select", "Male", "Female", "Other"])
	info.addField('Part. Age:  ')
	info.addField('Part. Year in School: ', 
		choices=["Please Select", "Freshman", "Sophmore", "Junior", 
		"Senior", "Graduate Student", "PhD Student","Other"])
	info.addField('Do you have normal or corrected-to-normal vision?', 
		choices=["Please Select", "Yes", "No"])
	info.addText('Experimenter Info')
	info.addField('Initials of Name:  ')
	info.show()
	if info.OK:
		infoData = info.data
	else:
		sys.exit()
	return infoData

def sart_textInst(win,instruction):
    inst = visual.TextStim(win, text=(instruction), color="white", units = "norm",height = 0.08, pos=(0, 0))
    event.clearEvents()
    while 'space' not in event.getKeys():
        inst.draw()
        win.flip()
    blank_inst1 = visual.TextStim(win, text="", color="white", units = "norm",height=0.05, pos=(0, 0))
    blank_inst1.draw()
    win.flip()

def probBlocks(win,instruction_self,scaleText,trigProb,trigProbResp):
    inst_self = visual.TextStim(win, text=(instruction_self), color="white", units = "norm",height=0.08, pos=(0, 0.5))
    inst_selfText = visual.TextStim(win, text=scaleText, color="white", units = "norm",height=0.06, pos=(0, 0.15),wrapWidth = 2)
    scale = visual.ImageStim(win,image = "TPs_Scale.jpg",pos = (0,0), units = "norm",size = (1,0.146))
    event.clearEvents()
    current_probFrame = 0
    probeTime2 = core.getTime()
    while current_probFrame < probframes:
        probResp_self = event.getKeys(keyList = ['1','2','3','4','5','6','7','8','9'])
        # ,timeStamped = False
        probeDur_2 = core.getTime()-probeTime2
        if not list(set(probResp_self) & set(['1','2','3','4','5','6','7','8','9'])):
            inst_self.draw()
            inst_selfText.draw()
            scale.draw()
            win.flip()
            if current_probFrame == 0:
                sendTrigger(trigProb)
            current_probFrame = current_probFrame + 1
#        if probeDur_2 >probeLimit:
#            break
        else:
            break
    if len(probResp_self) == 0:
        num_probResp_self = trigProbResp
    else:
        num_probResp_self = int(probResp_self[0])+trigProbResp
    sendTrigger(num_probResp_self)
    blank_inst = visual.TextStim(win, text="", color="white", units = "norm",height=0.05, pos=(0, 0))
    blank_inst.draw()
    win.flip()
    core.wait(1)
    return(num_probResp_self)
    
def sart_probQues(win, instruction,probframes):
    inst = visual.TextStim(win, text=(instruction), color="white", units = "norm",height=0.08, pos=(0, 0))
    event.clearEvents()
    current_probFrame = 0
    probeTime1 = core.getTime()
    while current_probFrame < probframes:
        probResp = event.getKeys(keyList = ['1','2','3','4','5','6'])
        # ,timeStamped = False
        probeDur_1 = core.getTime()-probeTime1
        if not list(set(probResp) & set(['1','2','3','4','5','6'])):
            inst.draw()
            win.flip()
            if current_probFrame == 0:
                sendTrigger(15)
            current_probFrame = current_probFrame + 1
#        if probeDur_1 >probeLimit:
#            break
        else:
            break
    if len(probResp) == 0:
        num_probResp = 30
    else:
        num_probResp = int(probResp[0])+30
    sendTrigger(num_probResp)
    blank_inst = visual.TextStim(win, text="", color="white", units = "norm",height=0.05, pos=(0, 0))
    blank_inst.draw()
    win.flip()
    core.wait(1)
    
    ## Self-related
    instruction_self = "To what extent were your thoughts self-focused?"
    scaleText_self = "completely not self-focused/about others         neither self nor other-focused         completely self-focused"
    trigProb_self = 16
    trigProbResp_self = 50
    num_probResp_self = probBlocks(win,instruction_self,scaleText_self,trigProb_self,trigProbResp_self)
    
    ## Thought negative/positive
    instruction_thought = "How positive or negative were your thoughts?"
    scaleText_thought = "very negative         neither negative nor positive         very positive"
    trigProb_thought = 17
    trigProbResp_thought = 70
    num_probResp_thought = probBlocks(win,instruction_thought,scaleText_thought,trigProb_thought,trigProbResp_thought)
    
    ## stickness
    instruction_stickness = "How difficult was it to disengage from the thought?"
    scaleText_stickness = "very easy            neither easy nor difficult            very difficult"
    trigProb_stickness = 18
    trigProbResp_stickness = 80
    num_probResp_stickness = probBlocks(win,instruction_stickness,scaleText_stickness,trigProb_stickness,trigProbResp_stickness)
    
    probResps = [num_probResp-30, num_probResp_self- trigProbResp_self, num_probResp_thought-trigProbResp_thought, num_probResp_stickness-trigProbResp_stickness]
    str_allKeys = [str(k).replace(',','-') for k in probResps]
    str_allKeys = '#'.join(str_allKeys)
    return(str_allKeys)

def sart_break_inst(win):
    inst = visual.TextStim(win, text=("You can now take a short break.\n\n Press the SPACE key when you are ready to continue."),
    color="white", units = "norm",height=0.08, pos=(0, 0))
    startTime = core.getTime()
    while ~any(x in ["space"] for x in event.getKeys()):
        eTime = core.getTime() - startTime
        inst.draw()
        win.flip()
        act_key = event.getKeys()
        if eTime > 180 or 'space' in act_key:
            break

triggerDuration = 20
triggerFrames = int(triggerDuration/msPerFrame)
def sendTrigger(code): 
    """ a routine for sending triggers"""
#    port.setData(0)
#    port.setData(code)
    P.Out32(0x378, code) # send the event code (could be 1-255)
    core.wait(0.01) # wait for 10 ms for the trigger to get registered
    P.Out32(0x378, 0) # send a code to clear the register 
    core.wait(0.01) # wait for 6 ms

def crs_flicker(win,crsStim,raw_crsFrames,testStim):
    current_frame = 0
    for current_frame in range(raw_crsFrames):
        on_flicker = int(current_frame) % numFrames_flicker
        if on_flicker in range(num_onFlicker):
            crsStim.draw()
    #			rectStim.draw()
#			rectStim_in.draw()
#            testStim.draw()
        win.flip()
        # current_frame += 1  # increment by 1.

def wordRect_flicker(win,wordStim,rectStim,rectStim_in,testStim,word_trigType):
    current_frame = 0
    t_ini = core.getTime()
    for current_frame in range(raw_wordFrames-triggerFrames+1):
        on_flicker = int(current_frame) % numFrames_flicker #4
        if on_flicker in [1,2]:#range(num_onFlicker):#[0,1]:
#            rectStim.draw()
#            rectStim_in.draw()
#            testStim.draw()
            wordStim.draw()
#        t_1 = core.getTime()
        win.flip()
#        t_2 = core.getTime()
#        print(t_2-t_1)
        if current_frame == 0:
            word_trigNo = int(word_trigType)
#            t_befTrigger = core.getTime()
#            win.flip()
#            win.flip()
            sendTrigger(word_trigNo)
#            t_frame = core.getTime()
#            print(word_trigType, t_befTrigger-t_ini,t_frame - t_befTrigger)
#        if current_frame == 1:
#            t_secFrame = core.getTime()
#            print(t_secFrame - t_frame)
        # current_frame += 1  # increment by 1.

def xRect_flicker(win,xStim,rectStim,rectStim_in,testStim):
    current_frame = 0
    for current_frame in range(raw_xFrames-1):
        on_flicker = int(current_frame) % numFrames_flicker
        if on_flicker in [2,3]:
            xStim.draw()
    #			rectStim.draw()
#			rectStim_in.draw()
#            testStim.draw()
        win.flip()
#        current_frame += 1  # increment by 1.



def squareSize(initial_rectH,initial_rectV):
#    hv_rect = initial_rect * screenSize[0]/10000
#    wv_rect = initial_rect * screenSize[1]/10000
    hv_rect = initial_rectH/2
    wv_rect = initial_rectV/2
    return(wv_rect,hv_rect)

def sart_block(win, dataFile,partInfo,fb, reps, bNum, fixed,trialList):
#    blankInterval = visual.TextStim(win,text = '+',units = 'pix',pos = (0,0),height = 100)
#    blankInterval.draw()
#    win.flip()
    sendTrigger(int(bNum)+90)
    event.waitKeys(maxWait=2)
    mouse = event.Mouse(visible=0)
    xStim = visual.TextStim(win, text="#####", units = "pix",height=200, pos = [0,0],bold = True,color="white")

    coRectX = 1080
    coRectY = 1920
#    coRect = 7.5
#    print(squareSize(coRect)[0],squareSize(coRect)[1])
#    rectStim = visual.ShapeStim(win,units = "deg", vertices =((-squareSize(coRect)[0],-squareSize(coRect)[1]),(squareSize(coRect)[0],-squareSize(coRect)[1]),(squareSize(coRect)[0],squareSize(coRect)[1]),(-squareSize(coRect)[0],squareSize(coRect)[1])))
    rectStim = visual.ShapeStim(win,units = "pix", vertices =((-squareSize(coRectX,coRectY)[0],-squareSize(coRectX,coRectY)[1]),(squareSize(coRectX,coRectY)[0],-squareSize(coRectX,coRectY)[1]),(squareSize(coRectX,coRectY)[0],squareSize(coRectX,coRectY)[1]),(-squareSize(coRectX,coRectY)[0],squareSize(coRectX,coRectY)[1])))
    rectStim.fillColor = [1,1,1]

    coRect_inX = 150
    coRect_inY = 150
#    coRect_in = 5.5
#    rectStim_in = visual.ShapeStim(win,units = "deg", vertices =((-squareSize(coRect_in)[0],-squareSize(coRect_in)[1]),(squareSize(coRect_in)[0],-squareSize(coRect_in)[1]),(squareSize(coRect_in)[0],squareSize(coRect_in)[1]),(-squareSize(coRect_in)[0],squareSize(coRect_in)[1])))
    rectStim_in = visual.ShapeStim(win,units = "pix", vertices =((-squareSize(coRect_inX,coRect_inY)[0],-squareSize(coRect_inX,coRect_inY)[1]),(squareSize(coRect_inX,coRect_inY)[0],-squareSize(coRect_inX,coRect_inY)[1]),(squareSize(coRect_inX,coRect_inY)[0],squareSize(coRect_inX,coRect_inY)[1]),(-squareSize(coRect_inX,coRect_inY)[0],squareSize(coRect_inX,coRect_inY)[1])))
    rectStim_in.fillColor = [-1,-1,-1]
    
    testRect = .01
    testStim = visual.ShapeStim(win,units = "norm", vertices =((0,0),(0.05625,0),(0.05625,0.1),(0,0.1)),fillColor = [1,1,1])
#    testStim = visual.ShapeStim(win,units = "norm", vertices =((0,0),(squareSize(testRect,testRect)[0],0),(squareSize(testRect,testRect)[0],squareSize(testRect,testRect)[1]),(0,squareSize(testRect,testRect)[1])))
#    testStim.fillColor = [1,1,1]
#    testStim.color = [1,1,1]
    testStim.pos = (-1,-.73)
    # wordStim = visual.TextStim(win, font="Arial", color="white", units = "norm",height=.1,alignHoriz='center', alignVert='center',pos = [0.0,0.0])
    # wordStim.pos = [0.75, 0]
    correctStim = visual.TextStim(win, text="CORRECT", color="green", units = "deg",alignHoriz='center', alignVert='center', pos = [0.0,0.0],
        font="Arial",  height=2)
    # correctStim.pos = [0.75, 0]
    incorrectStim = visual.TextStim(win, text="INCORRECT", color="red",units = "deg",alignHoriz='center', alignVert='center',pos = [0.0,0.0],
        font="Arial", height=2)
    arraysList = []
    for pars in trialList:
        for par in pars:
            arrays = par.split(";")
            arraysList.append(arrays)
#    print(arraysList)
    if fixed == True:
        wordList = data.TrialHandler(wordList, nReps=reps, method='sequential')
    # else:
    # 	trials = data.TrialHandler(list, nReps=reps, method='random')
    clock = core.Clock()
    tNum = 0
    for trials in arraysList:
        tNum += 1
        sart_trial(win, dataFile,partInfo,fb, xStim, rectStim,rectStim_in,testStim,correctStim, incorrectStim, clock, trials,tNum, bNum, mouse)#trials.thisTrial['word'],#trials.thisTrial['fontSize'], trials.thisTrial['word']

def sart_trial(win, dataFile,partInfo,fb, xStim, rectStim, rectStim_in, testStim, correctStim, 
    	incorrectStim, clock, trials, tNum, bNum, mouse):
            word, trialType, blockTrial, blockNum = trials
            startTime = core.getTime()
            mouse.setVisible(0)
            crsStim = visual.TextStim(win,text = '+',units = 'pix',pos = (0,0),height = 200)
#            crsDuration = random.sample([1500,1600,1700,1800,1900,2000,2100],1)
            crsDuration = random.sample([1480,1640,1800,1960,2120],1)
            raw_crsFrames = int(int(crsDuration[0])/msPerFrame)
#            raw_crsFrames = int(crsDuration/msPerFrame)
#            crsFrames = raw_crsFrames - 1
            crs_flicker(win,crsStim,raw_crsFrames,testStim)
            respRt = "NA"
            event.clearEvents()
            clock.reset()
            stimStartTime = core.getTime()
            if word == 'TP':
                str_allKeys = sart_probQues(win,prob_ques,1500)
#                str_allKeys = int(sart_probQues(win,prob_ques,1500))-30
                respAcc = '-'
                wordSize_X = '-'
                wordSize_Y = '_'
                maskStartTime = endTime = core.getTime()
                word_trigNo = int(trialType) + 10
#                sendTrigger(word_trigNo)
            else:	
                # wordStim.setText(word)
                wordStim = visual.TextStim(win, font="Arial", text = word, color="white", units = "pix",height=200,bold = True,pos = [0.0,0.0],wrapWidth = 1920 )
                wordSize = wordStim.boundingBox
                wordSize_X, wordSize_Y = wordSize
                word_trigNo = int(trialType) + 10
                wordRect_flicker(win,wordStim,rectStim,rectStim_in,testStim,word_trigNo)
                maskStartTime = core.getTime()
                xRect_flicker(win,xStim,rectStim,rectStim_in,testStim)
                blankStim = visual.TextStim(win, text="", color="white", units = "norm",height=0.05, pos=(0, 0))
                blankStim.draw()
                win.flip()
                core.wait(3)
                endTime = core.getTime()
                allKeys = event.getKeys(timeStamped=clock)
                str_allKeys = [str(k).replace(',','-') for k in allKeys]
                str_allKeys = '#'.join(str_allKeys)
                for key in allKeys:
                    if 'escape' in key:
                        print('User cancelled the procedure\n')
                        core.quit()
                if len(allKeys) != 0:
                    respRt = allKeys[0][1]
                if len(allKeys) == 0:
                    if word.isupper():
                        respAcc = 1
                        sendTrigger(66)
                    else:
                        respAcc = 0
                        sendTrigger(44)
                else:
                    if allKeys[0][0] != "n":
                        respAcc = 0
                        sendTrigger(55)
                    if allKeys[0][0] == "n":
                        if word.isupper():
                            respAcc = 0
                            sendTrigger(44)
                        else:
                            respAcc = 1
                            sendTrigger(66)
                ## Feedback during practice session
                if fb == True:
                    if respAcc == 0:
                        incorrectStim.draw()
                    else:
                        correctStim.draw()
                    fb_stimStartTime = core.getTime()
                    win.flip()
                    waitTime = .90 - (core.getTime() - fb_stimStartTime)
                    core.wait(waitTime, hogCPUperiod=waitTime)
                    win.flip()
            fb_endTime = core.getTime()
            trial_crsDuration = stimStartTime - startTime
            trial_wordDuration = maskStartTime - stimStartTime
            trial_maskDuration = endTime - maskStartTime
            trial_maskendDuration = endTime -stimStartTime
            totalTime = fb_endTime - startTime
            trialData = partInfo+[bNum,tNum,word,trialType, blockTrial, blockNum,raw_crsFrames,raw_wordFrames,raw_xFrames,word_trigNo,wordSize_X, wordSize_Y , str_allKeys,respAcc,respRt,startTime,stimStartTime,maskStartTime,endTime,fb_endTime,trial_crsDuration,trial_wordDuration,trial_maskDuration,trial_maskendDuration,totalTime]
            trialData = map(str, trialData) # change all elements to 'string' type
            dataFile.write(','.join(trialData) + '\n')


def sart(reps=1, practice=True,path="SART_SSVEP_csvData/", fixed=False):
    partInfo = part_info_gui()
    # partInfo)
    dataFile = initDataFile(partInfo,path)
    win = visual.Window(size = screenSize,color="black", units = 'norm',fullscr = True,
        monitor=mon)
    win.recordFrameIntervals = True
    # sart_init_inst(win)
    sart_textInst(win,init_inst)
    while practice == True:
        pracList = readList(rawpath,['pracList.csv'],0)
        # for pars in readList:
        ## Illustrate the response
        sart_textInst(win,prac_inst)
        sart_pracList = pracList[0:7]
        sart_block(win, dataFile,partInfo,fb=True, 
            reps=1, bNum=0, fixed=fixed,trialList = sart_pracList)
        ## Illusrate the probe
        sart_textInst(win,prob_inst)
        sart_probQues(win,prob_ques,9000)
        # print(pracList)
        pracList = random.sample(pracList,11)
        sart_block(win, dataFile,partInfo,fb=False, 
            reps=1, bNum=0, fixed=fixed,trialList = pracList)
#        sart_textInst(win,act_task_inst)
        event.clearEvents()
        while ~any(x in ["p","space"] for x in event.getKeys()):
            act_task  = visual.TextStim(win,text = (act_task_inst),color="white", units = "norm",height = 0.08, pos=(0, 0))
            act_task.draw()
            win.flip()
            blanks= visual.TextStim(win,text = "",color="white", units = "norm",height = 0.08, pos=(0, 0))
            act_key = event.getKeys()
            if 'space' in act_key:
                practice = False
                blanks.draw()
                win.flip()
                break
            elif 'p' in act_key:
                practice = True
                blanks.draw()
                win.flip()
                break
#        while len(event.getKeys()) == 0:
#        core.wait(10)
#        if 's' in act_key:
#            ## Deciding whether to keep practicing or not
#            prac2_inst = visual.TextStim(win, text=("To practice again, please press P button"), color="white", units = "norm",height = 0.05, pos=(0, 0))
#            prac2_inst.draw()
#            win.flip()
#        if 'space' in act_key:
#            practice = False
    for block in range(len(files)):
        trialList = readList(filepath,files,block)
        # print(trialList)
    #		trialList = random.sample(trialList,5) #### Please remove this in formal experiment
        sart_block(win, dataFile,partInfo,fb=False, 
            reps=reps, bNum=block+1, fixed=fixed,trialList = trialList)
        if (block % 2 == 0) and (block != 0):
            sart_break_inst(win)
    sendTrigger(99)
    dataFile.close()
    endInst = visual.TextStim(win, text=("This is the end of the experiment. Thank you for your participation!"),
color="white", units = "norm",height=0.08, pos=(0, 0))
    endInst.draw()
    win.flip()
    core.wait(3)
    win.refreshThreshold = 1/screen_frequency + 0.004
    logging.console.setLevel(logging.WARNING)
    print('Overall, %i frames were dropped.' % win.nDroppedFrames)
    # plt.plot(win.frameIntervals)
    # plt.show()
    
def main():
	sart()

if __name__ == "__main__":
	main()