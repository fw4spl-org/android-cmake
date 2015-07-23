import sys
import subprocess


ANDROID_APK_PACKAGE     = "com.fw4spl.DroidRender"
ACTIVITY_NAME           = ANDROID_APK_PACKAGE + "." + "LauncherActivity"    

# Overwrite default apk name and activity name if some were specified on the command line
if len(sys.argv) > 1 :
    ANDROID_APK_PACKAGE = sys.argv[1]

if len(sys.argv) > 2 :
    ACTIVITY_NAME = sys.argv[2]

### FIXME
# ANDROID_APK_PACKAGE     = "org.qtproject.example.openglwindow"
# ACTIVITY_NAME           = "org.qtproject.qt5.android.bindings.QtActivity"

###########################################################################################################################################################################################
CMD_FORCEQUIT_PROCESS   = "adb shell am force-stop " + ANDROID_APK_PACKAGE
CMD_START_PROCESS       = "adb shell am start " + ANDROID_APK_PACKAGE + "/" + ACTIVITY_NAME

    
# Make sure the Activity is not already running
subprocess.call(CMD_FORCEQUIT_PROCESS)

# Start the Activity
print "\n"
print " ==> Starting Activity " + ACTIVITY_NAME + " of APK " + ANDROID_APK_PACKAGE 
print "\t" + CMD_START_PROCESS + "\n"
subprocess.call(CMD_START_PROCESS)


###########################################################################################################################################################################################
# Get the PID of the process created for our Activity
CMD_GET_PID='adb shell "set `ps | grep ' + ANDROID_APK_PACKAGE + '` && echo $2" '

proc=subprocess.Popen(CMD_GET_PID, shell=True, stdout=subprocess.PIPE, )
output=proc.communicate()[0]

# /!\ HACK : necessary trick, without it the command CMD_GDBSERVER_ATTACH fails... most probably due to some invisible character
PID=str(int(output))

###########################################################################################################################################################################################
CMD_FORWARD_PORT_TO_PIPE    =   "adb forward tcp:5039 localfilesystem:/data/data/" + ANDROID_APK_PACKAGE + "/debug-socket"
CMD_GDBSERVER_ATTACH        =   "adb shell run-as " + ANDROID_APK_PACKAGE + " /data/data/" + ANDROID_APK_PACKAGE + "/lib/libgdbserver.so +debug-socket --attach " + PID

print "\n"
print " ==> Forward host port to remote unix pipe : "
print "\t" + CMD_FORWARD_PORT_TO_PIPE + "\n"
subprocess.call(CMD_FORWARD_PORT_TO_PIPE)   

### FIXME
# subprocess.call("adb forward tcp:20002 localabstract:" + ANDROID_APK_PACKAGE + ".ping_pong_socket")
# CMD_GDBSERVER_ATTACH        =   'adb shell am start -n ' + ANDROID_APK_PACKAGE + '/'  + ACTIVITY_NAME + ' -e debug_ping true -e ping_socket ' + ANDROID_APK_PACKAGE + '.ping_pong_socket -e gdbserver_command "/data/data/' + ANDROID_APK_PACKAGE + '/lib/libgdbserver.so --multi +/data/data/' + ANDROID_APK_PACKAGE + '/debug-socket" -e gdbserver_socket /data/data/' + ANDROID_APK_PACKAGE + '/debug-socket' 

print "\n"
print " ==> Attach gdbserver to the right process : "
print "\t" + CMD_GDBSERVER_ATTACH + "\n"
subprocess.call(CMD_GDBSERVER_ATTACH)   



###########################################################################################################################################################################################

# set auto-solib-add on
# set solib-search-path c:/Tmp/Nexus-10/system/lib;c:/Tmp/Nexus-10/vendor/lib;c:/Tmp/Nexus-10/;c:/test/FW4SPL/Install/Android/Debug/lib;c:/test/FW4SPL/Install/Android/Debug/apk/libs/armeabi-v7a

# set solib-search-path c:/test/FW4SPL/Install/Android/Debug/apk/libs\armeabi-v7a