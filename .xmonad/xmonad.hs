import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops(ewmh)
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.SpawnOnce
import Data.List
import qualified XMonad.StackSet as W
import XMonad.Layout.Spacing
import XMonad.Layout.ResizableTile
import XMonad.Layout.WindowArranger
import XMonad.Layout.NoBorders
import XMonad.Layout.Fullscreen
import XMonad.Layout.Circle
import XMonad.Layout.Gaps
import XMonad.Actions.CycleWS (prevWS, nextWS)
import System.IO

myWorkspaces 	:: [String]
myWorkspaces	= click $ [ " 一 ", " 二 ", " 三 ", " 四 ", " 五 "]
		  where click l = [ "^ca(1, xdotool key super+"
				  ++ show (n) ++ ")" ++ ws ++ "^ca()" |
				  (i,ws) <- zip [1..] l,
				  let n = i]

myManageHook = composeAll
	[ className =? "Gimp"	--> doFloat
	, className =? "firefox"	--> doFloat
	]

mKeys = [ ((modm, xK_d), spawn "dmenu_run -b")
	, ((modm, xK_w), spawn "urxvt")
	, ((modm, xK_c), kill)
	, ((modm, xK_Left), prevWS)
	, ((modm, xK_Right), nextWS)
	, ((modm .|. controlMask              , xK_s    ), sendMessage  Arrange         )
        , ((modm .|. controlMask .|. shiftMask, xK_s    ), sendMessage  DeArrange       )
        , ((modm .|. controlMask              , xK_Left ), sendMessage (MoveLeft      10))
        , ((modm .|. controlMask              , xK_Right), sendMessage (MoveRight     10))
        , ((modm .|. controlMask              , xK_Down ), sendMessage (MoveDown      10))
        , ((modm .|. controlMask              , xK_Up   ), sendMessage (MoveUp        10))
        , ((modm                 .|. shiftMask, xK_Left ), sendMessage (IncreaseLeft  10))
        , ((modm                 .|. shiftMask, xK_Right), sendMessage (IncreaseRight 10))
        , ((modm                 .|. shiftMask, xK_Down ), sendMessage (IncreaseDown  10))
        , ((modm                 .|. shiftMask, xK_Up   ), sendMessage (IncreaseUp    10))
        , ((modm .|. controlMask .|. shiftMask, xK_Left ), sendMessage (DecreaseLeft  10))
        , ((modm .|. controlMask .|. shiftMask, xK_Right), sendMessage (DecreaseRight 10))
        , ((modm .|. controlMask .|. shiftMask, xK_Down ), sendMessage (DecreaseDown  10))
        , ((modm .|. controlMask .|. shiftMask, xK_Up   ), sendMessage (DecreaseUp    10))
	, ((modm, xK_KP_Add), sequence_ [ sendMessage (IncreaseLeft 10)
					, sendMessage (IncreaseRight 10)
					, sendMessage (IncreaseUp 10)
					, sendMessage (IncreaseDown 10) 
					])
	, ((modm, xK_KP_Subtract), sequence_ [ sendMessage (DecreaseLeft 10)
  					     , sendMessage (DecreaseRight 10)
					     , sendMessage (DecreaseUp 10)
					     , sendMessage (DecreaseDown 10) 
					     ])
	] where modm = mod1Mask

startUp :: X()
startUp = do
	spawnOnce "picom --config $HOME/.config/picom/picom.conf"
	spawnOnce "./.fehbg"
	spawnOnce "xsetroot -cursor_name left_ptr"
	spawnOnce "xrdb -load .Xresources"

logbar h = do
	dynamicLogWithPP $ tryPP h
tryPP :: Handle -> PP
tryPP h = defaultPP
	{ ppOutput		= hPutStrLn h
	, ppCurrent		= dzenColor (fore) (blu1) . pad
	, ppVisible		= dzenColor (fore) (back) . pad
	, ppHidden		= dzenColor (fore) (back) . pad
	, ppHiddenNoWindows	= dzenColor (fore) (back) . pad
	, ppUrgent		= dzenColor (fore) (red1) . pad
	, ppOrder		= \(ws:l:t) -> [ws,l]
	, ppSep			= ""
	, ppLayout		= dzenColor (fore) (red1) .
				( \t -> case t of
					"Spacing 2 ResizableTall" -> "  " ++ i ++ "tile.xbm) TILE  "
					"Full" -> "  " ++ i ++ "dice1.xbm) FULLSCREEN  "
					"Circle" -> "  " ++ i ++ "dice2.xbm) CIRCLE  "
					_ -> "  " ++ i ++ "tile.xbm) TILE  "
				)
	} where i = "^i(/home/marionette/.local/share/icons/bitmap/"

-- color --

back = "#373e4d"
blu1 = "#4c566a"
red1 = "#FA5AA4"
fore = "#DEE3E0"

-----------


-- layout --

res = ResizableTall 1 (2/100) (1/2) []
ful = noBorders (fullscreenFull Full)

   -- useless gap --

layout = (gaps [(U, 42), (R, 8), (L, 8), (D, 8)] $ avoidStruts (spacing 2 $ res)) ||| Circle ||| ful 

------------

main = do
	bar <- spawnPipe panel
	info <- spawnPipe "./.config/dzen2/dzen.sh"
	xmonad $ ewmh $ defaultConfig
		{ manageHook = manageDocks <+> manageHook defaultConfig
		, layoutHook = windowArrange layout
		, startupHook = startUp
		, workspaces = myWorkspaces
		, modMask = mod1Mask
		, terminal = "urxvt"
		, borderWidth = 5
		, focusedBorderColor = "#4c566a" --"#404752"
		, normalBorderColor = "#373e4d" --"#343C48"
		, logHook = logbar bar
		} `additionalKeys` mKeys
		where panel = "dzen2 -fn 'M+ 1mn:style=Bold:size=10' -ta l -p -w 400 -y 10 -x 10 -h 24 -e ''"
