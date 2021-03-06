#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=C:\Program Files (x86)\AutoIt3\Aut2Exe\Icons\AutoIt_Old1.ico
#AutoIt3Wrapper_Outfile=GWA.exe
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include "include\engine.au3"
#include "include\getSkillID.au3"
#include "include\getSkillName.au3"

Initialize(WinGetProcess("Guild Wars"))

AutoItSetOption("GUIOnEventMode", 1)
AutoItSetOption("TrayIconDebug", 1)

HotKeySet("!e", "_OnOff")
HotKeySet("!x", "_Reset")
HotKeySet("!w", "_LockOnOff")
HotKeySet("!a", "_TargetOnOff")
HotKeySet("!v", "_MarksOnOff")
HotKeySet("!c", "_MarkTarget")
HotKeySet("!q", "_PauseOnOff")
HotKeySet("!{F1}", "_AntiRuptOnOff")
HotKeySet("!{F2}", "_RuptEverythingOnOff")
HotKeySet("!z", "_ShowEnemyParty")
HotKeySet("^1", "_ChangeStateOfSkill1")
HotKeySet("^2", "_ChangeStateOfSkill2")
HotKeySet("^3", "_ChangeStateOfSkill3")
HotKeySet("^4", "_ChangeStateOfSkill4")
HotKeySet("^5", "_ChangeStateOfSkill5")
HotKeySet("^t", "_ChangeStateOfSkill6")
HotKeySet("^g", "_ChangeStateOfSkill7")
HotKeySet("^b", "_ChangeStateOfSkill8")

HotKeySet("!{NUMPAD0}", "HideGUI")
HotKeySet("!{NUMPAD1}", "ShowGUI")
HotKeySet("!{NUMPAD4}", "HideTooltips")
HotKeySet("!{NUMPAD5}", "ShowTooltips")

#region gui
Global Const $hGUI = GUICreate("GWA revision25", 600, 400)
Global Const $hFileSets = @ScriptDir & "\config\skillsSets.ini"
Global Const $hFile = @ScriptDir & "\config\skills.ini"

Global $bEnabled = False
Global $bLockMode = False
Global $bTargetMode = False
Global $bMarkedMode = False
Global $bInterruptingPaused = False
Global $bAntiRuptEnabled = True
Global $bRuptEverythingEnabled = False
Global $bShowTooltips = True

Global $bBusy = False
Global $fMyTimer = 0
Global $bCasting = False
Global $fCastRemaining = 0
Global $fMyActivation = 0
Global $fMyAftercast = 0
Global $bDiversion = False
Global $fDiversionTimer = 0
Global $iDiversionedID = 0
Global $fMovementTimer = 0
Global $fMovementActivation = 0

Global $iFuseNr = 0
Global $iFuseTarget = 0
Global $fFuseTimer = 0

Global $sSkillsList[9]
Global $aSkillsChecked[9]
Global Const $sBullsList = ",237,332,843,853,1023,1146,2808,"
Global Const $sAntiRupt = "399,1726,409,426,61,3185,932,57,1053,1342,1344,860,408,1992,5,25,953,24,803,1994,931,23,1403"
Global $sFullList = $sBullsList & $sAntiRupt
Global Const $aHotkeys[9] = ["", "q", "w", "e", "r", "a", "s", "d", "f"]

Global $iTargeted = 0
Global $sMarkedTargets = ","

Global $hSkills[9]
Global $hFunction[9]
Global $hSkillType[9]
Global $hLabelDelay[9]
Global $hDelay[9]
Global $hLabelDistance[9]
Global $hDistance[9]
Global $hResource[9]
Global $hLabelAmount[9]
Global $hAmount[9]
Global $hLabelActivation[9]
Global $hActivation[9]
Global $hLabelDontUse[9]
Global $hDiversion[9]
Global $hBlind[9]
Global $hBackfire[9]
Global $hShame[9]
Global $hUseSkills[9]

Global $aFunction[9]
Global $aSkillType[9]
Global $aDelay[9]
Global $aDistance[9]
Global $aResource[9]
Global $aAmount[9]
Global $aActivation[9]
Global $aDiversion[9]
Global $aBlind[9]
Global $aBackfire[9]
Global $aShame[9]

GUISetOnEvent($GUI_EVENT_CLOSE, "EventHandler")
GUISetFont(10)
Global $hMenu = GUICtrlCreateMenu("")
GUICtrlSetState(-1, $GUI_DISABLE)
Global $hSaveSkillSet = GUICtrlCreateMenuItem("Save Skill Set", -1)
GUICtrlSetOnEvent(-1, "EventHandler")
Global $hSaveSkill = GUICtrlCreateMenuItem("Save Skill", -1)
GUICtrlSetOnEvent(-1, "EventHandler")
Global $hDeleteSkillSet = GUICtrlCreateMenuItem("Delete Skill Set", -1)
GUICtrlSetOnEvent(-1, "EventHandler")
Global $hDeleteSkill = GUICtrlCreateMenuItem("Delete Skill ", -1)
GUICtrlSetOnEvent(-1, "EventHandler")
Global $hClear = GUICtrlCreateMenuItem("Clear", -1)
GUICtrlSetOnEvent(-1, "EventHandler")
Global $hTab = GUICtrlCreateTab(10, 10, 580, 250)
For $i = 1 To 8 Step 1
	GUICtrlCreateTabItem("Skill " & $i)
	$hSkills[$i] = GUICtrlCreateEdit("", 20, 40, 560, 130, BitOR($ES_MULTILINE, $WS_VSCROLL))

	$hFunction[$i] = GUICtrlCreateCombo("", 20, 180, 100, 20, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_DROPDOWNLIST))
	GUICtrlSetData(-1, "Interrupt|Protection|Self-Defense", "Interrupt")
	GUICtrlSetOnEvent(-1, "EventHandler")

	$hSkillType[$i] = GUICtrlCreateCombo("", 20, 205, 100, 20, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_DROPDOWNLIST))
	GUICtrlSetData(-1, "SpellEnemy|SkillEnemy|Attack Skill|Signet", "SpellEnemy")

	$hLabelDelay[$i] = GUICtrlCreateLabel("Delay:", 140, 182)
	$hDelay[$i] = GUICtrlCreateInput("", 200, 180, 45, 20)

	$hLabelDistance[$i] = GUICtrlCreateLabel("Distance:", 140, 207)
	$hDistance[$i] = GUICtrlCreateInput("", 200, 205, 45, 20)

	$hResource[$i] = GUICtrlCreateCombo("", 300, 180, 100, 20, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_DROPDOWNLIST))
	GUICtrlSetData(-1, "Energy|Adrenaline", "Energy")

	$hLabelAmount[$i] = GUICtrlCreateLabel("Amount:", 300, 207)
	$hAmount[$i] = GUICtrlCreateInput("", 350, 205, 45, 20)

	$hLabelActivation[$i] = GUICtrlCreateLabel("Activation Time:", 420, 182)
	$hActivation[$i] = GUICtrlCreateInput("", 520, 180, 45, 20)

	$hLabelDontUse[$i] = GUICtrlCreateLabel("Don't use skill if:", 20, 232)
	$hDiversion[$i] = GUICtrlCreateCheckbox("Diversion", 140, 230)
	$hBlind[$i] = GUICtrlCreateCheckbox("Blind", 220, 230)
	$hBackfire[$i] = GUICtrlCreateCheckbox("Backfire", 300, 230)
	$hShame[$i] = GUICtrlCreateCheckbox("Shame", 380, 230)
Next
GUICtrlCreateTabItem("")
Global $hActiveSkills = GUICtrlCreateLabel("Active skills", 20, 267)
For $i = 1 To 8 Step 1
	$hUseSkills[$i] = GUICtrlCreateCheckbox($i, 100 + 30 * ($i - 1), 265)
	GUICtrlSetOnEvent(-1, "EventHandler")
Next
Global $hLockMode = GUICtrlCreateCheckbox("Lock Mode", 20, 290)
GUICtrlSetOnEvent(-1, "EventHandler")
Global $hTargetMode = GUICtrlCreateCheckbox("Target Mode", 20, 315)
GUICtrlSetOnEvent(-1, "EventHandler")
Global $hMarkedMode = GUICtrlCreateCheckbox("Marked Mode", 20, 340)
GUICtrlSetOnEvent(-1, "EventHandler")

Global $hSkill = GUICtrlCreateCombo("", 350, 265, 200, 20, BitOR($CBS_SORT, $GUI_SS_DEFAULT_COMBO, $CBS_DROPDOWNLIST))
GUICtrlSetOnEvent(-1, "EventHandler")
Global $hSkillSet = GUICtrlCreateCombo("", 350, 290, 200, 20, BitOR($CBS_SORT, $GUI_SS_DEFAULT_COMBO, $CBS_DROPDOWNLIST))
GUICtrlSetOnEvent(-1, "EventHandler")
Global $hOnOff = GUICtrlCreateButton("Enable", 350, 315, 70, 40)
GUICtrlSetOnEvent(-1, "EventHandler")
#endregion gui

#region main_functions
Func CheckDiversion($objCaster, $objTarget, $objSkill)
	If $bDiversion == True Then
		;~ if the person under diversion uses a skill, clear variables
		If DllStructGetData($objCaster, 'ID') == $iDiversionedID Then
			$bDiversion = False
			$iDiversionedID = 0
			$fDiversionTimer = 0
		EndIf
	EndIf
	;~ check if casted spell is diversion
	If DllStructGetData($objSkill, 'ID') == 30 Then
		;~ check if it was casted by non-enemy
		If DllStructGetData($objCaster, 'Allegiance') <> 0x3 Then
			;~ set variables
			$bDiversion = True
			$iDiversionedID = DllStructGetData($objTarget, 'ID')
			$fDiversionTimer = TimerInit()
		EndIf
	EndIf
EndFunc

Func CheckRupt($objCaster, $objTarget, $objSkill, $fTime)
	;~ make sure its turned on
	If $bEnabled == 0 Then
		Return
	EndIf
	Local $fDistance, $fCastingTime, $fExtraTime, $objConfirmation, $iConfirmation, $sWarning, $iType
	;~ start timer to calculate processing time
	Local $fProcessingTime = TimerInit()
	;~ check if i'm the one casting, note it for later
	If DllStructGetData($objCaster, 'ID') == GetMyID() Then
		$bBusy = False
		$fMyTimer = TimerInit()
		$fMyActivation = $fTime * 1000
		$bCasting = True
		$fMyAftercast = 1000 * DllStructGetData($objSkill, 'Aftercast')
		Return
	EndIf
	If $bRuptEverythingEnabled == False Then
		;~ check if skill that's being used is on the list
		If StringInStr($sFullList, "," & String(DllStructGetData($objSkill, 'ID')) & ",") == 0 Then
			Return
		EndIf
	EndIf
	;~ check if target is diversioned
	If $iDiversionedID == DllStructGetData($objCaster, 'ID') Then
		Return
	EndIf
	;~ check if agent is enemy
	If DllStructGetData($objCaster, 'Allegiance') == 0x3 Then
		If DllStructGetData($objTarget, 'ID') == GetMyID() Then
			If StringInStr($sAntiRupt, "," & String(DllStructGetData($objSkill, 'ID')) & ",") And $bAntiRuptEnabled == True Then
				If 1000 * $fTime < $fMyActivation - TimerDiff($fMyTimer) Then
					If GetIsCasting(-2) Then
						CancelAction()
						Return
					EndIf
				EndIf
			EndIf
			If StringInStr($sBullsList, "," & String(DllStructGetData($objSkill, 'ID')) & ",") Then
				$fMovementTimer = TimerInit()
				$fMovementActivation = 1000 * $fTime
				AdlibRegister("DodgeBulls", 20)
				Return
			EndIf
		EndIf
		;~ 	get needed info
		Local $objSkillbar = GetSkillBar()
		Local $objOwnInfo = GetAgentByID(-2)
		Local $iTarget = GetCurrentTargetID()
		For $i = 1 To 8 Step 1
			;~ check if your skill checked
			If $aSkillsChecked[$i] == "On" Then
				;~ check if your skill is recharging
				If DllStructGetData($objSkillbar, "Recharge" & $i) == 0 Then
					;~ check if enough energy/adrenaline
					If (($aResource[$i] == "Energy") And (GetEnergy() >= $aAmount[$i])) Or (($aResource[$i] == "Adrenaline") And (GetSkillbarSkillAdrenaline($i + 1) >= 25 * $aAmount[$i])) Then
						If $aFunction[$i] == "Interrupt" And Not $bInterruptingPaused Then
							;~ calculate distance to caster
							$fDistance = GetDistance($objOwnInfo, $objCaster)
							If $aDistance[$i] >= $fDistance Then
								;~ check targeting mode
								If ($bLockMode == True) Or ($bTargetMode == True) Or ($bMarkedMode == True) Then
									;~ check if caster is on your current target, your locked target or one of your marked targets
									If (DllStructGetData($objCaster, 'ID') == $iTarget) Or (DllStructGetData($objCaster, 'ID') == $iTargeted) _
									Or StringInStr($sMarkedTargets, "," & String(DllStructGetData($objCaster, 'ID')) & ",") <> 0 Then
										If $bRuptEverythingEnabled == True Then
											$iConfirmation = DllStructGetData($objSkill, 'ID')
											;~ check type of a skill
											Switch $aSkillType[$i]
												;~ check if interrupt is attack skill
												Case "Attack Skill"
													If $aActivation[$i] > 0 Then
														$fCastingTime = $aActivation[$i] * DllStructGetData($objOwnInfo, 'AttackSpeedModifier') + $fDistance * 0.42
													Else
														$fCastingTime = DllStructGetData($objOwnInfo, 'AttackSpeed') * DllStructGetData($objOwnInfo, 'AttackSpeedModifier') + $fDistance * 0.42
													EndIf
												;~ check if interrupt is signet
												Case "Signet"
													$fCastingTime = $aActivation[$i] * (1 - 0.03 * GetAttributeByID(0, True))
												;~ check if interrupt is spell and can interrupt only spells and chants
												Case "SpellEnemy"
													$fCastingTime = $aActivation[$i] * .5 ^ (GetAttributeByID(0, True) / 15)
													$iType = DllStructGetData($objSkill, 'Type')
													If $iType == 7 Or $iType == 10 Or $iType == 12 Or $iType == 14 Or $iType == 19 Or $iType == 21 Or $iType == 22 Or $iType == 26 Or $iType == 28 Then
														ContinueLoop
													EndIf
												;~ check if interrupt is spell and can interrupt every skill
												Case "SkillEnemy"
													$fCastingTime = $aActivation[$i] * .5 ^ (GetAttributeByID(0, True) / 15)
											EndSwitch
											;~ calculate remaining time after ping, your spell, and time processing the code
											$fExtraTime = ($fTime * 1000 - (TimerDiff($fProcessingTime) + $fCastRemaining + (1.3 * GetPing())))
											;~ check if it's possible to rupt while waiting the min reaction time
											If $fExtraTime >= ($fCastingTime + $aDelay[$i]) Then
												If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
													$fExtraTime = Random($aDelay[$i] - TimerDiff($fProcessingTime), ($fExtraTime - $fCastingTime) * .8, 1)
													$bBusy = True ;Ready
													ChangeTarget($objCaster)
													Sleep($fExtraTime+10)
													$objConfirmation = GetAgentByID(-1)
													If DllStructGetData($objConfirmation, 'Skill') == $iConfirmation Then
														Send($aHotkeys[$i])
														$bBusy = False
														Return
													EndIf
												EndIf
											EndIf
										Else
											;~ check if skill is on right list
											If StringInStr($sSkillsList[$i], "," & String(DllStructGetData($objSkill, 'ID')) & ",") Then
												$iConfirmation = DllStructGetData($objSkill, 'ID')
												;~ check type of a skill
												Switch $aSkillType[$i]
													;~ check if interrupt is attack skill
													Case "Attack Skill"
														If $aActivation[$i] > 0 Then
															$fCastingTime = $aActivation[$i] * DllStructGetData($objOwnInfo, 'AttackSpeedModifier') + $fDistance * 0.42
														Else
															$fCastingTime = DllStructGetData($objOwnInfo, 'AttackSpeed') * DllStructGetData($objOwnInfo, 'AttackSpeedModifier') + $fDistance * 0.42
														EndIf
													;~ check if interrupt is signet
													Case "Signet"
														$fCastingTime = $aActivation[$i] * (1 - 0.03 * GetAttributeByID(0, True))
													;~ check if interrupt is spell and can interrupt only spells and chants
													Case "SpellEnemy"
														$fCastingTime = $aActivation[$i] * .5 ^ (GetAttributeByID(0, True) / 15)
														$iType = DllStructGetData($objSkill, 'Type')
														If $iType == 7 Or $iType == 10 Or $iType == 12 Or $iType == 14 Or $iType == 19 Or $iType == 21 Or $iType == 22 Or $iType == 26 Or $iType == 28 Then
															ContinueLoop
														EndIf
													;~ check if interrupt is spell and can interrupt every skill
													Case "SkillEnemy"
														$fCastingTime = $aActivation[$i] * .5 ^ (GetAttributeByID(0, True) / 15)
												EndSwitch
												;~ calculate remaining time after ping, your spell, and time processing the code
												$fExtraTime = ($fTime * 1000 - (TimerDiff($fProcessingTime) + $fCastRemaining + (1.3 * GetPing())))
												;~ check if it's possible to rupt while waiting the min reaction time
												If $fExtraTime >= ($fCastingTime + $aDelay[$i]) Then
													If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
														$fExtraTime = Random($aDelay[$i] - TimerDiff($fProcessingTime), ($fExtraTime - $fCastingTime) * .8, 1)
														$bBusy = True ;Ready
														ChangeTarget($objCaster)
														Sleep($fExtraTime+10)
														$objConfirmation = GetAgentByID(-1)
														If DllStructGetData($objConfirmation, 'Skill') == $iConfirmation Then
															Send($aHotkeys[$i])
															$bBusy = False
															Return
														EndIf
													EndIf
												EndIf
											EndIf
										EndIf
									EndIf
								;~ if all targets are viable then
								Else
									If StringInStr($sSkillsList[$i], "," & String(DllStructGetData($objSkill, 'ID')) & ",") Then
										$iConfirmation = DllStructGetData($objSkill, 'ID')
										;~ check type of a skill
										Switch $aSkillType[$i]
											;~ check if interrupt is attack skill
											Case "Attack Skill"
												If $aActivation[$i] > 0 Then
													$fCastingTime = $aActivation[$i] * DllStructGetData($objOwnInfo, 'AttackSpeedModifier') + $fDistance * 0.42
												Else
													$fCastingTime = DllStructGetData($objOwnInfo, 'AttackSpeed') * DllStructGetData($objOwnInfo, 'AttackSpeedModifier') + $fDistance * 0.42
												EndIf
											;~ check if interrupt is signet
											Case "Signet"
												$fCastingTime = $aActivation[$i] * (1 - 0.03 * GetAttributeByID(0, True))
											;~ check if interrupt is spell and can interrupt only spells and chants
											Case "SpellEnemy"
												$fCastingTime = $aActivation[$i] * .5 ^ (GetAttributeByID(0, True) / 15)
												$iType = DllStructGetData($objSkill, 'Type')
												If $iType == 7 Or $iType == 10 Or $iType == 12 Or $iType == 14 Or $iType == 19 Or $iType == 21 Or $iType == 22 Or $iType == 26 Or $iType == 28 Then
													ContinueLoop
												EndIf
											;~ check if interrupt is spell and can interrupt every skill
											Case "SkillEnemy"
												$fCastingTime = $aActivation[$i] * .5 ^ (GetAttributeByID(0, True) / 15)
										EndSwitch
										;~ calculate remaining time after ping, your spell, and time processing the code
										$fExtraTime = ($fTime * 1000 - (TimerDiff($fProcessingTime) + $fCastRemaining + (1.3 * GetPing())))
										;~ check if it's possible to rupt while waiting the min reaction time
										If $fExtraTime >= ($fCastingTime + $aDelay[$i]) Then
											If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
												$fExtraTime = Random($aDelay[$i] - TimerDiff($fProcessingTime), ($fExtraTime - $fCastingTime) * .8, 1)
												$bBusy = True ;Ready
												ChangeTarget($objCaster)
												Sleep($fExtraTime+10)
												$objConfirmation = GetAgentByID(-1)
												If DllStructGetData($objConfirmation, 'Skill') == $iConfirmation Then
													Send($aHotkeys[$i])
													$bBusy = False
													Return
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						ElseIf $aFunction[$i] == "Protection" And Not $bInterruptingPaused Then
							;~ calculate distance to target
							$fDistance = GetDistance($objOwnInfo, $objTarget)
							If $aDistance[$i] >= $fDistance Then
								If StringInStr($sSkillsList[$i], "," & String(DllStructGetData($objSkill, 'ID')) & ",") Then
									;~ calculate time needed to activate spell
									$fCastingTime = $aActivation[$i]
									$fExtraTime = ($fTime * 1000 - (TimerDiff($fProcessingTime) + $fCastRemaining + (1.3 * GetPing())))
									;~ check type of a skill
									Switch $aSkillType[$i]
										Case "ProtAlly"
											;~ check if it's possible to use prot in time
											If $fExtraTime >= $fCastingTime Then
												If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
													$bBusy = True ;Ready
													If ($fExtraTime - $fCastingTime) >= 0 Then
														$fExtraTime = Random(0, ($fExtraTime - $fCastingTime) * .55, 1)
														Sleep($fExtraTime)
													EndIf
													ChangeTarget($objTarget)
													If $bShowTooltips == True Then
														$sWarning = "watch for " & GetPlayerNumber($objTarget) & @CRLF
														$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
														ToolTip($sWarning, 1000, 600)
													EndIf
													Sleep(25)
													Send($aHotkeys[$i])
													$bBusy = False
													Return
												EndIf
											EndIf
										Case "ProtOtherAlly"
											If DllStructGetData($objTarget, 'ID') <> GetMyID() Then
												;~ check if it's possible to use prot in time
												If $fExtraTime >= $fCastingTime Then
													If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
														$bBusy = True ;Ready
														If ($fExtraTime - $fCastingTime) >= 0 Then
															$fExtraTime = Random(0, ($fExtraTime - $fCastingTime) * .55, 1)
															Sleep($fExtraTime)
														EndIf
														ChangeTarget($objTarget)
														If $bShowTooltips == True Then
															$sWarning = "watch for " & GetPlayerNumber($objTarget) & @CRLF
															$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
															ToolTip($sWarning, 1000, 600)
														EndIf
														Sleep(25)
														Send($aHotkeys[$i])
														$bBusy = False
														Return
													EndIf
												EndIf
											EndIf
										Case "HealAlly"
											If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
												$bBusy = True ;Ready
												If $fExtraTime >= $fCastingTime Then
													$fExtraTime = Random($fExtraTime-$fCastingTime+100, $fExtraTime-$fCastingTime+175, 1)
													Sleep($fExtraTime)
												EndIf
												ChangeTarget($objTarget)
												If $bShowTooltips == True Then
													$sWarning = "heal on " & GetPlayerNumber($objTarget) & @CRLF
													$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
													ToolTip($sWarning, 1000, 600)
												EndIf
												Sleep(25)
												Send($aHotkeys[$i])
												$bBusy = False
												Return
											EndIf
										Case "HealOtherAlly"
											If DllStructGetData($objTarget, 'ID') <> GetMyID() Then
												If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
													$bBusy = True ;Ready
													If $fExtraTime >= $fCastingTime Then
														$fExtraTime = Random($fExtraTime-$fCastingTime+100, $fExtraTime-$fCastingTime+175, 1)
														Sleep($fExtraTime)
													EndIf
													ChangeTarget($objTarget)
													If $bShowTooltips == True Then
														$sWarning = "heal on " & GetPlayerNumber($objTarget) & @CRLF
														$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
														ToolTip($sWarning, 1000, 600)
													EndIf
													Sleep(25)
													Send($aHotkeys[$i])
													$bBusy = False
													Return
												EndIf
											EndIf
										Case "Veil"
											If DllStructGetData($objTarget, 'ID') <> GetMyID() Then
												If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
													$bBusy = True ;Ready
													If ($fExtraTime - $fCastingTime) >= 0 Then
														$fExtraTime = Random(0, ($fExtraTime - $fCastingTime) * .55, 1)
														Sleep($fExtraTime)
													EndIf
													ChangeTarget($objTarget)
													If $bShowTooltips == True Then
														$sWarning = "hex on " & GetPlayerNumber($objTarget) & @CRLF
														$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
														ToolTip($sWarning, 1000, 600)
													EndIf
													Sleep(25)
													Send($aHotkeys[$i])
													$bBusy = False
													Return
												EndIf
											Else
												If $fExtraTime >= $fCastingTime Then
													If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
														$bBusy = True ;Ready
														If ($fExtraTime - $fCastingTime) >= 0 Then
															$fExtraTime = Random(0, ($fExtraTime - $fCastingTime) * .55, 1)
															Sleep($fExtraTime)
														EndIf
														ChangeTarget($objTarget)
														If $bShowTooltips == True Then
															$sWarning = "hex on ME" &  @CRLF
															$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
															ToolTip($sWarning, 1000, 600)
														EndIf
														Sleep(25)
														Send($aHotkeys[$i])
														$bBusy = False
														Return
													EndIf
												EndIf
											EndIf
										Case "Fuse"
											If DllStructGetData($objTarget, 'ID') <> GetMyID() Then
												If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
													$bBusy = True ;Ready
													If $fExtraTime >= $fCastingTime Then
														$fExtraTime = Random($fExtraTime-$fCastingTime+100, $fExtraTime-$fCastingTime+175, 1)
														Sleep($fExtraTime)
													EndIf
													If $bShowTooltips == True Then
														$sWarning = "fuse on " & GetPlayerNumber($objTarget) & @CRLF
														$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
														ToolTip($sWarning, 1000, 600)
													EndIf
													$iFuseTarget = DllStructGetData($objTarget, 'ID')
													$iFuseNr = $i
													$fFuseTimer = TimerInit()
													AdlibRegister("CheckForFuse", 20)
													$bBusy = False
													Return
												EndIf
											EndIf
									EndSwitch
								EndIf
							EndIf
						ElseIf $aFunction[$i] == "Self-Defense" Then
							;~ check if enemy's skill is on the list
							If StringInStr($sSkillsList[$i], "," & String(DllStructGetData($objSkill, 'ID')) & ",") Then
								;~ check if you are the target
								If DllStructGetData($objTarget, 'ID') == GetMyID() Then
									;~ calculate time needed to activate spell
									$fCastingTime = $aActivation[$i]
									$fExtraTime = ($fTime * 1000 - (TimerDiff($fProcessingTime) + $fCastRemaining + (1.3 * GetPing())))
									;~ check if it's stance or dervish_stance (you can't use them while being kd and while using other skills)
									If $aSkillType[$i] == "Stance" Then
										If Not CheckHarmfulEffects($i) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
											$bBusy = True ;Ready
											If $fExtraTime >= 0 Then
												$fExtraTime = Random(0, $fExtraTime * .6, 1)
												Sleep($fExtraTime+10)
											EndIf
											Send($aHotkeys[$i])
											$bBusy = False
											Return
										EndIf
									ElseIf $aSkillType[$i] == "DervishStance" Then
										If Not CheckHarmfulEffects($i) And Not GetIsDead($objOwnInfo) And Not GetIsKnocked($objOwnInfo) And Not $bBusy Then
											$bBusy = True ;Ready
											If DllStructGetData($objOwnInfo, 'Skill') <> 0 Then
												Send("{ESCAPE}")
											EndIf
											If $fExtraTime >= 0 Then
												$fExtraTime = Random(0, $fExtraTime * .6, 1)
												Sleep($fExtraTime+10)
											EndIf
											Send($aHotkeys[$i])
											$bBusy = False
											Return
										EndIf
									EndIf
								EndIf
							EndIf
						ElseIf $aFunction[$i] == "Protection" And $bInterruptingPaused Then
							;~ calculate distance to target
							$fDistance = GetDistance($objOwnInfo, $objTarget)
							If $aDistance[$i] >= $fDistance Then
								If StringInStr($sSkillsList[$i], "," & String(DllStructGetData($objSkill, 'ID')) & ",") Then
									;~ check type of a skill
									Switch $aSkillType[$i]
										Case "ProtAlly"
											If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
												$bBusy = True ;Ready
												ChangeTarget($objTarget)
												If $bShowTooltips == True Then
														$sWarning = "watch for " & GetPlayerNumber($objTarget) & @CRLF
														$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
														ToolTip($sWarning, 1000, 600)
												EndIf
												$bBusy = False
												Return
											EndIf
										Case "ProtOtherAlly"
											If DllStructGetData($objTarget, 'ID') <> GetMyID() Then
												If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
													$bBusy = True ;Ready
													ChangeTarget($objTarget)
													If $bShowTooltips == True Then
														$sWarning = "watch for " & GetPlayerNumber($objTarget) & @CRLF
														$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
														ToolTip($sWarning, 1000, 600)
													EndIf
													$bBusy = False
													Return
												EndIf
											EndIf
										Case "HealAlly"
											If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
												$bBusy = True ;Ready
												ChangeTarget($objTarget)
												If $bShowTooltips == True Then
													$sWarning = "heal on " & GetPlayerNumber($objTarget) & @CRLF
													$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
													ToolTip($sWarning, 1000, 600)
												EndIf
												$bBusy = False
												Return
											EndIf
										Case "HealOtherAlly"
											If DllStructGetData($objTarget, 'ID') <> GetMyID() Then
												If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
													$bBusy = True ;Ready
													ChangeTarget($objTarget)
													If $bShowTooltips == True Then
														$sWarning = "heal on " & GetPlayerNumber($objTarget) & @CRLF
														$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
														ToolTip($sWarning, 1000, 600)
													EndIf
													$bBusy = False
													Return
												EndIf
											EndIf
										Case "Veil"
											If DllStructGetData($objTarget, 'ID') <> GetMyID() Then
												If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
													$bBusy = True ;Ready
													ChangeTarget($objTarget)
													If $bShowTooltips == True Then
														$sWarning = "heal on " & GetPlayerNumber($objTarget) & @CRLF
														$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
														ToolTip($sWarning, 1000, 600)
													EndIf
													$bBusy = False
													Return
												EndIf
											Else
												If $fExtraTime >= $fCastingTime Then
													If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
														$bBusy = True ;Ready
														ChangeTarget($objTarget)
														If $bShowTooltips == True Then
															$sWarning = "hex on " & GetPlayerNumber($objTarget) & @CRLF
															$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
															ToolTip($sWarning, 1000, 600)
														EndIf
														$bBusy = False
														Return
													EndIf
												EndIf
											EndIf
										Case "Fuse"
											If DllStructGetData($objTarget, 'ID') <> GetMyID() Then
												If Not CheckHarmfulEffects($i) And Not GetIsKnocked($objOwnInfo) And Not GetIsDead($objOwnInfo) And Not $bBusy Then
													$bBusy = True ;Ready
													ChangeTarget($objTarget)
													If $bShowTooltips == True Then
														$sWarning = "fuse on " & GetPlayerNumber($objTarget) & @CRLF
														$sWarning &= $i & "___" & GetSkillName(DllStructGetData($objSkill, 'ID'))
														ToolTip($sWarning, 1000, 600)
													EndIf
													$bBusy = False
													Return
												EndIf
											EndIf
									EndSwitch
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	EndIf
EndFunc   ;==>CheckRupt

Func DodgeBulls()
	If GetIsMoving(-2) Then CancelAction()
	If TimerDiff($fMovementTimer) > $fMovementActivation Then AdlibUnRegister("DodgeBulls")
EndFunc   ;==>DodgeBulls

Func CheckForFuse()
	$objTarget = GetAgentByID($iFuseTarget)
	If (DllStructGetData($objTarget, 'HP')) < 0.45 Then
		UseFuse($objTarget, $iFuseNr)
	EndIf
	If TimerDiff($fFuseTimer) > 2250 Then AdlibUnRegister("CheckForFuse")
EndFunc   ;==>CheckForFuse

Func UseFuse($objTarget, $i)
	AdlibUnRegister("CheckForFuse")
	ChangeTarget($objTarget)
	Sleep(20)
	Send($aHotkeys[$i])
EndFunc   ;==>UseFuse
#endregion main_functions

#region event_handlers
Func EventHandler()
	Switch (@GUI_CtrlId)
		Case $GUI_EVENT_CLOSE
			Exit
		Case $hOnOff
			_OnOff()
		Case $hClear
			Select
				Case GUICtrlRead($hSkills[1]) <> "" Or GUICtrlRead($hSkills[2]) <> "" Or GUICtrlRead($hSkills[3]) <> "" Or GUICtrlRead($hSkills[4]) <> "" Or GUICtrlRead($hSkills[5]) <> "" Or GUICtrlRead($hSkills[6]) <> "" Or GUICtrlRead($hSkills[7]) <> "" Or GUICtrlRead($hSkills[8]) <> ""
					$hGoThrough = MsgBox(1, "Clear skills", "Are you sure you want to clear the current skills?")
					If $hGoThrough = 1 Then
						For $i = 1 To 8 Step 1
							GUICtrlSetState($hUseSkills[$i], $GUI_UNCHECKED)
							GUICtrlSetData($hSkills[$i], "")
							GUICtrlSetData($hFunction[$i], "Interrupt")
							GUICtrlSetData($hSkillType[$i], "|SpellEnemy|SkillEnemy|Attack Skill|Signet", "SpellEnemy")
							GUICtrlSetData($hDelay[$i], "")
							GUICtrlSetState($hDelay[$i], $GUI_ENABLE)
							GUICtrlSetData($hDistance[$i], "")
							GUICtrlSetState($hDistance[$i], $GUI_ENABLE)
							GUICtrlSetData($hResource[$i], "Energy")
							GUICtrlSetData($hAmount[$i], "")
							GUICtrlSetData($hActivation[$i], "")
							GUICtrlSetState($hDiversion[$i], $GUI_UNCHECKED)
							GUICtrlSetState($hBlind[$i], $GUI_UNCHECKED)
							GUICtrlSetState($hBackfire[$i], $GUI_UNCHECKED)
							GUICtrlSetState($hShame[$i], $GUI_UNCHECKED)
						Next
						UpdateSkillSets()
						UpdateSkills()
					EndIf
				Case Else
					MsgBox(48, "No skills to clear", "You cannot clear the current skills when there are none!")
			EndSelect
		Case $hSaveSkillSet
			Select
				Case GUICtrlRead($hSkills[1]) <> "" Or GUICtrlRead($hSkills[2]) <> "" Or GUICtrlRead($hSkills[3]) <> "" Or GUICtrlRead($hSkills[4]) <> "" Or GUICtrlRead($hSkills[5]) <> "" Or GUICtrlRead($hSkills[6]) <> "" Or GUICtrlRead($hSkills[7]) <> "" Or GUICtrlRead($hSkills[8]) <> ""
					Local $hSaveName = InputBox("Save skillset", "Please enter a name for the skillset you're saving", GUICtrlRead($hSkillSet))
					Select
						Case Not @error And $hSaveName <> ""
							For $i = 1 To 8 Step 1
								IniWrite($hFileSets, $hSaveName, "UseSkill_" & $i, GUICtrlRead($hUseSkills[$i]))
								IniWrite($hFileSets, $hSaveName, "Skill_" & $i, GUICtrlRead($hSkills[$i]))
								IniWrite($hFileSets, $hSaveName, "Function_" & $i, GUICtrlRead($hFunction[$i]))
								IniWrite($hFileSets, $hSaveName, "SkillType_" & $i, GUICtrlRead($hSkillType[$i]))
								Switch GUICtrlRead($hFunction[$i])
									Case "Interrupt"
										IniWrite($hFileSets, $hSaveName, "Delay_" & $i, GUICtrlRead($hDelay[$i]))
										IniWrite($hFileSets, $hSaveName, "Distance_" & $i, GUICtrlRead($hDistance[$i]))
									Case "Protection"
										IniWrite($hFileSets, $hSaveName, "Distance_" & $i, GUICtrlRead($hDistance[$i]))
									Case "Self-Defense"
								EndSwitch
								IniWrite($hFileSets, $hSaveName, "Resource_" & $i, GUICtrlRead($hResource[$i]))
								IniWrite($hFileSets, $hSaveName, "Amount_" & $i, GUICtrlRead($hAmount[$i]))
								IniWrite($hFileSets, $hSaveName, "Activation_" & $i, GUICtrlRead($hActivation[$i]))
								IniWrite($hFileSets, $hSaveName, "Diversion_" & $i, GUICtrlRead($hDiversion[$i]))
								IniWrite($hFileSets, $hSaveName, "Blind_" & $i, GUICtrlRead($hBlind[$i]))
								IniWrite($hFileSets, $hSaveName, "Backfire_" & $i, GUICtrlRead($hBackfire[$i]))
								IniWrite($hFileSets, $hSaveName, "Shame_" & $i, GUICtrlRead($hShame[$i]))
							Next
							UpdateSkillSets()
							UpdateSkills()
							GUICtrlSetData($hSkillSet, $hSaveName)
						Case Not @error And $hSaveName = ""
							MsgBox(48, "No name", "You forgot to specify a name for the skillset!")
					EndSelect
				Case Else
					MsgBox(48, "No skills written", "You didn't write any skills into any of the lists!")
			EndSelect
		Case $hSaveSkill
			Select
				Case GUICtrlRead($hSkills[GUICtrlRead($hTab) + 1]) <> ""
					Local $hSaveName = InputBox("Save skill", "Please enter a name for the skill you're saving", GUICtrlRead($hSkill))
					Select
						Case Not @error And $hSaveName <> ""
							For $i = 1 To 8 Step 1
								IniWrite($hFile, $hSaveName, "UseSkill", GUICtrlRead($hUseSkills[GUICtrlRead($hTab) + 1]))
								IniWrite($hFile, $hSaveName, "Skill", GUICtrlRead($hSkills[GUICtrlRead($hTab) + 1]))
								IniWrite($hFile, $hSaveName, "Function", GUICtrlRead($hFunction[GUICtrlRead($hTab) + 1]))
								IniWrite($hFile, $hSaveName, "SkillType", GUICtrlRead($hSkillType[GUICtrlRead($hTab) + 1]))
								Switch GUICtrlRead($hFunction[GUICtrlRead($hTab) + 1])
									Case "Interrupt"
										IniWrite($hFile, $hSaveName, "Delay", GUICtrlRead($hDelay[GUICtrlRead($hTab) + 1]))
										IniWrite($hFile, $hSaveName, "Distance", GUICtrlRead($hDistance[GUICtrlRead($hTab) + 1]))
									Case "Protection"
										IniWrite($hFile, $hSaveName, "Distance", GUICtrlRead($hDistance[GUICtrlRead($hTab) + 1]))
									Case "Self-Defense"
								EndSwitch
								IniWrite($hFile, $hSaveName, "Resource", GUICtrlRead($hResource[GUICtrlRead($hTab) + 1]))
								IniWrite($hFile, $hSaveName, "Amount", GUICtrlRead($hAmount[GUICtrlRead($hTab) + 1]))
								IniWrite($hFile, $hSaveName, "Activation", GUICtrlRead($hActivation[GUICtrlRead($hTab) + 1]))
								IniWrite($hFile, $hSaveName, "Diversion", GUICtrlRead($hDiversion[GUICtrlRead($hTab) + 1]))
								IniWrite($hFile, $hSaveName, "Blind", GUICtrlRead($hBlind[GUICtrlRead($hTab) + 1]))
								IniWrite($hFile, $hSaveName, "Backfire", GUICtrlRead($hBackfire[GUICtrlRead($hTab) + 1]))
								IniWrite($hFile, $hSaveName, "Shame", GUICtrlRead($hShame[GUICtrlRead($hTab) + 1]))
							Next
							UpdateSkillSets()
							UpdateSkills()
							GUICtrlSetData($hSkill, $hSaveName)
						Case Not @error And $hSaveName = ""
							MsgBox(48, "No name", "You forgot to specify a name for the skillset!")
					EndSelect
				Case Else
					MsgBox(48, "No skills written", "You didn't write any skills into any of the lists!")
			EndSelect
		Case $hDeleteSkillSet
			Select
				Case GUICtrlRead($hSkillSet) <> ""
					$hGoThrough = MsgBox(1, "Delete skillset", "Are you sure you want to delete skillset " & GUICtrlRead($hSkillSet) & "?")
					If $hGoThrough = 1 Then
						IniDelete($hFileSets, GUICtrlRead($hSkillSet))
						UpdateSkillSets()
						UpdateSkills()
					EndIf
				Case Else
					MsgBox(48, "No skillset selected", "You have to select the skillset you wish to delete!")
			EndSelect
		Case $hDeleteSkill
			Select
				Case GUICtrlRead($hSkill) <> ""
					$hGoThrough = MsgBox(1, "Delete skill", "Are you sure you want to delete skill " & GUICtrlRead($hSkill) & "?")
					If $hGoThrough = 1 Then
						IniDelete($hFile, GUICtrlRead($hSkill))
						UpdateSkillSets()
						UpdateSkills()
					EndIf
				Case Else
					MsgBox(48, "No skill selected", "You have to select the skill you wish to delete!")
			EndSelect
		Case $hSkillSet
			For $i = 1 To 8 Step 1
				GUICtrlSetState($hUseSkills[$i], IniRead($hFileSets, GUICtrlRead($hSkillSet), "UseSkill_" & $i, ""))
				GUICtrlSetData($hSkills[$i], IniRead($hFileSets, GUICtrlRead($hSkillSet), "Skill_" & $i, ""))
				GUICtrlSetData($hFunction[$i], IniRead($hFileSets, GUICtrlRead($hSkillSet), "Function_" & $i, ""))
				Switch GUICtrlRead($hFunction[$i])
					Case "Interrupt"
						GUICtrlSetData($hSkillType[$i], "|SpellEnemy|SkillEnemy|Attack Skill|Signet", IniRead($hFileSets, GUICtrlRead($hSkillSet), "SkillType_" & $i, "SpellEnemy"))
						GUICtrlSetState($hDelay[$i], $GUI_ENABLE)
						GUICtrlSetState($hDistance[$i], $GUI_ENABLE)
					Case "Protection"
						GUICtrlSetData($hSkillType[$i], "|ProtAlly|ProtOtherAlly|HealAlly|HealOtherAlly|Veil|Fuse", IniRead($hFileSets, GUICtrlRead($hSkillSet), "SkillType_" & $i, "ProtAlly"))
						GUICtrlSetState($hDelay[$i], $GUI_DISABLE)
						GUICtrlSetState($hDistance[$i], $GUI_ENABLE)
					Case "Self-Defense"
						GUICtrlSetData($hSkillType[$i], "|Stance|DervishStance", IniRead($hFileSets, GUICtrlRead($hSkillSet), "SkillType_" & $i, "Stance"))
						GUICtrlSetState($hDelay[$i], $GUI_DISABLE)
						GUICtrlSetState($hDistance[$i], $GUI_DISABLE)
				EndSwitch
				GUICtrlSetData($hDelay[$i], IniRead($hFileSets, GUICtrlRead($hSkillSet), "Delay_" & $i, ""))
				GUICtrlSetData($hDistance[$i], IniRead($hFileSets, GUICtrlRead($hSkillSet), "Distance_" & $i, ""))
				GUICtrlSetData($hResource[$i], IniRead($hFileSets, GUICtrlRead($hSkillSet), "Resource_" & $i, ""))
				GUICtrlSetData($hAmount[$i], IniRead($hFileSets, GUICtrlRead($hSkillSet), "Amount_" & $i, ""))
				GUICtrlSetData($hActivation[$i], IniRead($hFileSets, GUICtrlRead($hSkillSet), "Activation_" & $i, ""))
				GUICtrlSetState($hDiversion[$i], IniRead($hFileSets, GUICtrlRead($hSkillSet), "Diversion_" & $i, ""))
				GUICtrlSetState($hBlind[$i], IniRead($hFileSets, GUICtrlRead($hSkillSet), "Blind_" & $i, ""))
				GUICtrlSetState($hBackfire[$i], IniRead($hFileSets, GUICtrlRead($hSkillSet), "Backfire_" & $i, ""))
				GUICtrlSetState($hShame[$i], IniRead($hFileSets, GUICtrlRead($hSkillSet), "Shame_" & $i, ""))
			Next
		Case $hSkill
			GUICtrlSetState($hUseSkills[GUICtrlRead($hTab) + 1], IniRead($hFile, GUICtrlRead($hSkill), "UseSkill", ""))
			GUICtrlSetData($hSkills[GUICtrlRead($hTab) + 1], IniRead($hFile, GUICtrlRead($hSkill), "Skill", ""))
			GUICtrlSetData($hFunction[GUICtrlRead($hTab) + 1], IniRead($hFile, GUICtrlRead($hSkill), "Function", ""))
			Switch GUICtrlRead($hFunction[GUICtrlRead($hTab) + 1])
				Case "Interrupt"
					GUICtrlSetData($hSkillType[GUICtrlRead($hTab) + 1], "|SpellEnemy|SkillEnemy|Attack Skill|Signet", IniRead($hFile, GUICtrlRead($hSkill), "SkillType", "SpellEnemy"))
					GUICtrlSetState($hDelay[GUICtrlRead($hTab) + 1], $GUI_ENABLE)
					GUICtrlSetState($hDistance[GUICtrlRead($hTab) + 1], $GUI_ENABLE)
				Case "Protection"
					GUICtrlSetData($hSkillType[GUICtrlRead($hTab) + 1], "|ProtAlly|ProtOtherAlly|HealAlly|HealOtherAlly|Veil|Fuse", IniRead($hFile, GUICtrlRead($hSkill), "SkillType", "ProtAlly"))
					GUICtrlSetState($hDelay[GUICtrlRead($hTab) + 1], $GUI_DISABLE)
					GUICtrlSetState($hDistance[GUICtrlRead($hTab) + 1], $GUI_ENABLE)
				Case "Self-Defense"
					GUICtrlSetData($hSkillType[GUICtrlRead($hTab) + 1], "|Stance|DervishStance", IniRead($hFile, GUICtrlRead($hSkill), "SkillType", "Stance"))
					GUICtrlSetState($hDelay[GUICtrlRead($hTab) + 1], $GUI_DISABLE)
					GUICtrlSetState($hDistance[GUICtrlRead($hTab) + 1], $GUI_DISABLE)
			EndSwitch
			GUICtrlSetData($hResource[GUICtrlRead($hTab) + 1], IniRead($hFile, GUICtrlRead($hSkill), "Resource", ""))
			GUICtrlSetData($hAmount[GUICtrlRead($hTab) + 1], IniRead($hFile, GUICtrlRead($hSkill), "Amount", ""))
			GUICtrlSetData($hActivation[GUICtrlRead($hTab) + 1], IniRead($hFile, GUICtrlRead($hSkill), "Activation", ""))
			GUICtrlSetData($hDelay[GUICtrlRead($hTab) + 1], IniRead($hFile, GUICtrlRead($hSkill), "Delay", ""))
			GUICtrlSetData($hDistance[GUICtrlRead($hTab) + 1], IniRead($hFile, GUICtrlRead($hSkill), "Distance", ""))
			GUICtrlSetState($hDiversion[GUICtrlRead($hTab) + 1], IniRead($hFile, GUICtrlRead($hSkill), "Diversion", ""))
			GUICtrlSetState($hBlind[GUICtrlRead($hTab) + 1], IniRead($hFile, GUICtrlRead($hSkill), "Blind", ""))
			GUICtrlSetState($hBackfire[GUICtrlRead($hTab) + 1], IniRead($hFile, GUICtrlRead($hSkill), "Backfire", ""))
			GUICtrlSetState($hShame[GUICtrlRead($hTab) + 1], IniRead($hFile, GUICtrlRead($hSkill), "Shame", ""))
		Case $hLockMode
			_LockOnOff()
		Case $hTargetMode
			_TargetOnOff()
		Case $hMarkedMode
			_MarksOnOff()
		Case $hFunction[1]
			If GUICtrlRead($hFunction[1]) == "Interrupt" Then
				GUICtrlSetData($hSkillType[1], "|SpellEnemy|SkillEnemy|Attack Skill|Signet", "SpellEnemy")
				GUICtrlSetState($hDelay[1], $GUI_ENABLE)
				GUICtrlSetState($hDistance[1], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[1]) == "Protection" Then
				GUICtrlSetData($hSkillType[1], "|ProtAlly|ProtOtherAlly|HealAlly|HealOtherAlly|Veil|Fuse", "ProtAlly")
				GUICtrlSetState($hDelay[1], $GUI_DISABLE)
				GUICtrlSetState($hDistance[1], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[1]) == "Self-Defense" Then
				GUICtrlSetData($hSkillType[1], "|Stance|DervishStance", "Stance")
				GUICtrlSetState($hDelay[1], $GUI_DISABLE)
				GUICtrlSetState($hDistance[1], $GUI_DISABLE)
			EndIf
		Case $hFunction[2]
			If GUICtrlRead($hFunction[2]) == "Interrupt" Then
				GUICtrlSetData($hSkillType[2], "|SpellEnemy|SkillEnemy|Attack Skill|Signet", "SpellEnemy")
				GUICtrlSetState($hDelay[2], $GUI_ENABLE)
				GUICtrlSetState($hDistance[2], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[2]) == "Protection" Then
				GUICtrlSetData($hSkillType[2], "|ProtAlly|ProtOtherAlly|HealAlly|HealOtherAlly|Veil|Fuse", "ProtAlly")
				GUICtrlSetState($hDelay[2], $GUI_DISABLE)
				GUICtrlSetState($hDistance[2], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[2]) == "Self-Defense" Then
				GUICtrlSetData($hSkillType[2], "|Stance|DervishStance", "Stance")
				GUICtrlSetState($hDelay[2], $GUI_DISABLE)
				GUICtrlSetState($hDistance[2], $GUI_DISABLE)
			EndIf
		Case $hFunction[3]
			If GUICtrlRead($hFunction[3]) == "Interrupt" Then
				GUICtrlSetData($hSkillType[3], "|SpellEnemy|SkillEnemy|Attack Skill|Signet", "SpellEnemy")
				GUICtrlSetState($hDelay[3], $GUI_ENABLE)
				GUICtrlSetState($hDistance[3], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[3]) == "Protection" Then
				GUICtrlSetData($hSkillType[3], "|ProtAlly|ProtOtherAlly|HealAlly|HealOtherAlly|Veil|Fuse", "ProtAlly")
				GUICtrlSetState($hDelay[3], $GUI_DISABLE)
				GUICtrlSetState($hDistance[3], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[3]) == "Self-Defense" Then
				GUICtrlSetData($hSkillType[3], "|Stance|DervishStance", "Stance")
				GUICtrlSetState($hDelay[3], $GUI_DISABLE)
				GUICtrlSetState($hDistance[3], $GUI_DISABLE)
			EndIf
		Case $hFunction[4]
			If GUICtrlRead($hFunction[4]) == "Interrupt" Then
				GUICtrlSetData($hSkillType[4], "|SpellEnemy|SkillEnemy|Attack Skill|Signet", "SpellEnemy")
				GUICtrlSetState($hDelay[4], $GUI_ENABLE)
				GUICtrlSetState($hDistance[4], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[4]) == "Protection" Then
				GUICtrlSetData($hSkillType[4], "|ProtAlly|ProtOtherAlly|HealAlly|HealOtherAlly|Veil|Fuse", "ProtAlly")
				GUICtrlSetState($hDelay[4], $GUI_DISABLE)
				GUICtrlSetState($hDistance[4], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[4]) == "Self-Defense" Then
				GUICtrlSetData($hSkillType[4], "|Stance|DervishStance", "Stance")
				GUICtrlSetState($hDelay[4], $GUI_DISABLE)
				GUICtrlSetState($hDistance[4], $GUI_DISABLE)
			EndIf
		Case $hFunction[5]
			If GUICtrlRead($hFunction[5]) == "Interrupt" Then
				GUICtrlSetData($hSkillType[5], "|SpellEnemy|SkillEnemy|Attack Skill|Signet", "SpellEnemy")
				GUICtrlSetState($hDelay[5], $GUI_ENABLE)
				GUICtrlSetState($hDistance[5], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[5]) == "Protection" Then
				GUICtrlSetData($hSkillType[5], "|ProtAlly|ProtOtherAlly|HealAlly|HealOtherAlly|Veil|Fuse", "ProtAlly")
				GUICtrlSetState($hDelay[5], $GUI_DISABLE)
				GUICtrlSetState($hDistance[5], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[5]) == "Self-Defense" Then
				GUICtrlSetData($hSkillType[5], "|Stance|DervishStance", "Stance")
				GUICtrlSetState($hDelay[5], $GUI_DISABLE)
				GUICtrlSetState($hDistance[5], $GUI_DISABLE)
			EndIf
		Case $hFunction[6]
			If GUICtrlRead($hFunction[6]) == "Interrupt" Then
				GUICtrlSetData($hSkillType[6], "|SpellEnemy|SkillEnemy|Attack Skill|Signet", "SpellEnemy")
				GUICtrlSetState($hDelay[6], $GUI_ENABLE)
				GUICtrlSetState($hDistance[6], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[6]) == "Protection" Then
				GUICtrlSetData($hSkillType[6], "|ProtAlly|ProtOtherAlly|HealAlly|HealOtherAlly|Veil|Fuse", "ProtAlly")
				GUICtrlSetState($hDelay[6], $GUI_DISABLE)
				GUICtrlSetState($hDistance[6], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[6]) == "Self-Defense" Then
				GUICtrlSetData($hSkillType[6], "|Stance|DervishStance", "Stance")
				GUICtrlSetState($hDelay[6], $GUI_DISABLE)
				GUICtrlSetState($hDistance[6], $GUI_DISABLE)
			EndIf
		Case $hFunction[7]
			If GUICtrlRead($hFunction[7]) == "Interrupt" Then
				GUICtrlSetData($hSkillType[7], "|SpellEnemy|SkillEnemy|Attack Skill|Signet", "SpellEnemy")
				GUICtrlSetState($hDelay[7], $GUI_ENABLE)
				GUICtrlSetState($hDistance[7], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[7]) == "Protection" Then
				GUICtrlSetData($hSkillType[7], "|ProtAlly|ProtOtherAlly|HealAlly|HealOtherAlly|Veil|Fuse", "ProtAlly")
				GUICtrlSetState($hDelay[7], $GUI_DISABLE)
				GUICtrlSetState($hDistance[7], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[7]) == "Self-Defense" Then
				GUICtrlSetData($hSkillType[7], "|Stance|DervishStance", "Stance")
				GUICtrlSetState($hDelay[7], $GUI_DISABLE)
				GUICtrlSetState($hDistance[7], $GUI_DISABLE)
			EndIf
		Case $hFunction[8]
			If GUICtrlRead($hFunction[8]) == "Interrupt" Then
				GUICtrlSetData($hSkillType[8], "|SpellEnemy|SkillEnemy|Attack Skill|Signet", "SpellEnemy")
				GUICtrlSetState($hDelay[8], $GUI_ENABLE)
				GUICtrlSetState($hDistance[8], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[8]) == "Protection" Then
				GUICtrlSetData($hSkillType[8], "|ProtAlly|ProtOtherAlly|HealAlly|HealOtherAlly|Veil|Fuse", "ProtAlly")
				GUICtrlSetState($hDelay[8], $GUI_DISABLE)
				GUICtrlSetState($hDistance[8], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[8]) == "Self-Defense" Then
				GUICtrlSetData($hSkillType[8], "|Stance|DervishStance", "Stance")
				GUICtrlSetState($hDelay[8], $GUI_DISABLE)
				GUICtrlSetState($hDistance[8], $GUI_DISABLE)
			EndIf
	EndSwitch
EndFunc   ;==>EventHandler

Func UpdateSkillSets()
	GUICtrlSetData($hSkillSet, "")
	Local $hNames = IniReadSectionNames($hFileSets)
	If @error == 0 Then
		For $i = 1 To $hNames[0] Step 1
			GUICtrlSetData($hSkillSet, $hNames[$i])
		Next
	EndIf
EndFunc   ;==>UpdateSkillSets

Func UpdateSkills()
	GUICtrlSetData($hSkill, "")
	Local $hNames = IniReadSectionNames($hFile)
	If @error == 0 Then
		For $i = 1 To $hNames[0] Step 1
			GUICtrlSetData($hSkill, $hNames[$i])
		Next
	EndIf
EndFunc   ;==>UpdateSkills
#endregion event_handlers

#region on_off
Func _OnOff()
	$bEnabled = Not $bEnabled
	If $bEnabled Then
		If $bShowTooltips == True Then
			ToolTip("ON", 0, 0, "Information", 1)
		EndIf
		GUICtrlSetData($hOnOff, "Disable")
		For $i = 1 To 8 Step 1
			GUICtrlSetState($hUseSkills[$i], $GUI_DISABLE)
			GUICtrlSetState($hSkills[$i], $GUI_DISABLE)
			GUICtrlSetState($hFunction[$i], $GUI_DISABLE)
			GUICtrlSetState($hSkillType[$i], $GUI_DISABLE)
			GUICtrlSetState($hDelay[$i], $GUI_DISABLE)
			GUICtrlSetState($hDistance[$i], $GUI_DISABLE)
			GUICtrlSetState($hResource[$i], $GUI_DISABLE)
			GUICtrlSetState($hAmount[$i], $GUI_DISABLE)
			GUICtrlSetState($hActivation[$i], $GUI_DISABLE)
			GUICtrlSetState($hDiversion[$i], $GUI_DISABLE)
			GUICtrlSetState($hBlind[$i], $GUI_DISABLE)
			GUICtrlSetState($hBackfire[$i], $GUI_DISABLE)
			GUICtrlSetState($hShame[$i], $GUI_DISABLE)
		Next
		GUICtrlSetState($hSkillSet, $GUI_DISABLE)
		GUICtrlSetState($hSkill, $GUI_DISABLE)

		For $i = 1 To 8 Step 1
			$sSkillsList[$i] = GetSkillsIDs(GUICtrlRead($hSkills[$i]))
			If GUICtrlRead($hUseSkills[$i]) = $GUI_CHECKED Then
				$aSkillsChecked[$i] = "On"
			Else
				$aSkillsChecked[$i] = "Off"
			EndIf
		Next

		SaveDataToVars()
		SetEvent("CheckRupt", "", "CheckDiversion", "", "Load")
	Else
		GUICtrlSetData($hOnOff, "Enable")
		If $bShowTooltips == True Then
			ToolTip("OFF", 0, 0, "Information", 1)
		EndIf
		$sFullList = $sBullsList & $sAntiRupt

		For $i = 1 To 8 Step 1
			GUICtrlSetState($hUseSkills[$i], $GUI_ENABLE)
			GUICtrlSetState($hSkills[$i], $GUI_ENABLE)
			GUICtrlSetState($hFunction[$i], $GUI_ENABLE)
			If GUICtrlRead($hFunction[$i]) == "Interrupt" Then
				GUICtrlSetState($hDelay[$i], $GUI_ENABLE)
				GUICtrlSetState($hDistance[$i], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[$i]) == "Protection" Then
				GUICtrlSetState($hDelay[$i], $GUI_DISABLE)
				GUICtrlSetState($hDistance[$i], $GUI_ENABLE)
			ElseIf GUICtrlRead($hFunction[$i]) == "Self-Defense" Then
				GUICtrlSetState($hDelay[$i], $GUI_DISABLE)
				GUICtrlSetState($hDistance[$i], $GUI_DISABLE)
			EndIf
			GUICtrlSetState($hSkillType[$i], $GUI_ENABLE)
			GUICtrlSetState($hResource[$i], $GUI_ENABLE)
			GUICtrlSetState($hAmount[$i], $GUI_ENABLE)
			GUICtrlSetState($hActivation[$i], $GUI_ENABLE)
			GUICtrlSetState($hDiversion[$i], $GUI_ENABLE)
			GUICtrlSetState($hBlind[$i], $GUI_ENABLE)
			GUICtrlSetState($hBackfire[$i], $GUI_ENABLE)
			GUICtrlSetState($hShame[$i], $GUI_ENABLE)
		Next
		GUICtrlSetState($hSkillSet, $GUI_ENABLE)
		GUICtrlSetState($hSkill, $GUI_ENABLE)
		SetEvent("", "", "", "", "Load")
	EndIf
EndFunc   ;==>_OnOff

Func GetSkillsIDs($sList)
	Local $sReturnString = ","
	;~ split whole string to smalled ids
	Local $sSplitList = StringSplit($sList, ",")
	;~ convert string values to ids values
	For $i = 1 To $sSplitList[0] Step 1
		$sSplitList[$i] = GetSkillID(StringStripCR(StringStripWS($sSplitList[$i], 3)))
	Next
	;~ add converted ids to skills list and unique id to full list
	For $i = 1 To $sSplitList[0] Step 1
		If $sSplitList[$i] <> -1 Then
			$sReturnString = $sReturnString & $sSplitList[$i] & ","
			If StringInStr($sFullList, "," & $sSplitList[$i] & ",") == 0 Then
				$sFullList = $sFullList & $sSplitList[$i] & ","
			EndIf
		EndIf
	Next
	Return $sReturnString
EndFunc   ;==>GetSkillsIDs

Func SaveDataToVars()
	For $i = 1 To 8 Step 1
		$aFunction[$i] = GUICtrlRead($hFunction[$i])
		$aSkillType[$i] = GUICtrlRead($hSkillType[$i])
		$aDelay[$i] = GUICtrlRead($hDelay[$i])
		$aDistance[$i] = GUICtrlRead($hDistance[$i])
		$aResource[$i] = GUICtrlRead($hResource[$i])
		$aAmount[$i] = GUICtrlRead($hAmount[$i])
		$aActivation[$i] = GUICtrlRead($hActivation[$i])
		$aDiversion[$i] = GUICtrlRead($hDiversion[$i])
		$aBlind[$i] = GUICtrlRead($hBlind[$i])
		$aBackfire[$i] = GUICtrlRead($hBackfire[$i])
		$aShame[$i] = GUICtrlRead($hShame[$i])
	Next

	For $i = 1 To 8 Step 1
		If $aDiversion[$i] = 4 Then $aDiversion[$i] = 0
		If $aBlind[$i] = 4 Then $aBlind[$i] = 0
		If $aBackfire[$i] = 4 Then $aBackfire[$i] = 0
		If $aShame[$i] = 4 Then $aShame[$i] = 0
	Next
EndFunc   ;==>SaveDataToVars
#endregion on_off


#region helper_functions
Func CheckHarmfulEffects($iNumber)
	Local $objCheck
	If $aDiversion[$iNumber] = 1 Then
		$objCheck = GetEffect(30)
		If DllStructGetData($objCheck, 'SkillID') <> 0 Then
			Return True
		EndIf
	EndIf
	If $aBlind[$iNumber] = 1 Then
		$objCheck = GetEffect(479)
		If DllStructGetData($objCheck, 'SkillID') <> 0 Then
			Return True
		EndIf
	EndIf
	If $aShame[$iNumber] = 1 Then
		$objCheck = GetEffect(51)
		If DllStructGetData($objCheck, 'SkillID') <> 0 Then
			Return True
		EndIf
	EndIf
	If $aBackfire[$iNumber] = 1 Then
		$objCheck = GetEffect(28)
		If DllStructGetData($objCheck, 'SkillID') <> 0 Then
			Return True
		EndIf
	EndIf
	Return False
EndFunc   ;==>CheckHarmfulEffects
#endregion helper_functions

#region targeting_functions
Func _LockOnOff()

	$bLockMode = Not $bLockMode
	$bTargetMode = False
	GUICtrlSetState($hTargetMode, $GUI_UNCHECKED)
	$bMarkedMode = False
	GUICtrlSetState($hMarkedMode, $GUI_UNCHECKED)

	If $bLockMode Then
		GUICtrlSetState($hLockMode, $GUI_CHECKED)
		If $bShowTooltips == True Then
			ToolTip("Switched to LOCK Mode", 0, 0, "Information", 1)
		EndIf
	Else
		GUICtrlSetState($hLockMode, $GUI_UNCHECKED)
		If $bShowTooltips == True Then
			ToolTip("Switched to NORMAL Mode", 0, 0, "Information", 1)
		EndIf
	EndIf
EndFunc   ;==>_LockOnOff

Func _TargetOnOff()

	Local $objOwnInfo = GetAgentByID(-2)
	Local $objTarget = GetAgentByID(-1)

	If DllStructGetData($objOwnInfo, 'Team') <> DllStructGetData($objTarget, 'Team') Then
		$bTargetMode = Not $bTargetMode
		$bLockMode = False
		GUICtrlSetState($hLockMode, $GUI_UNCHECKED)
		$bMarkedMode = False
		GUICtrlSetState($hMarkedMode, $GUI_UNCHECKED)
		If $bTargetMode == True Then
			GUICtrlSetState($hTargetMode, $GUI_CHECKED)
			$iTargeted = DllStructGetData($objTarget, 'ID')
			If $bShowTooltips == True Then
				ToolTip(FormatName($objTarget), 0, 0, "Target Info", 1)
			EndIf
		Else
			GUICtrlSetState($hTargetMode, $GUI_UNCHECKED)
			$iTargeted = 0
			If $bShowTooltips == True Then
				ToolTip("Switched to NORMAL Mode", 0, 0, "Information", 1)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>_TargetOnOff

Func _MarksOnOff()
	$bMarkedMode = Not $bMarkedMode
	$sMarkedTargets = ","

	$bLockMode = False
	GUICtrlSetState($hLockMode, $GUI_UNCHECKED)
	$bTargetMode = False
	GUICtrlSetState($hTargetMode, $GUI_UNCHECKED)

	If $bMarkedMode == True Then
		GUICtrlSetState($hMarkedMode, $GUI_CHECKED)
		If $bShowTooltips == True Then
			ToolTip("Switched to MARKED Mode", 0, 0, "Information", 1)
		EndIf
	Else
		GUICtrlSetState($hMarkedMode, $GUI_UNCHECKED)
		If $bShowTooltips == True Then
			ToolTip("Switched to NORMAL mode", 0, 0, "Information", 1)
		Endif
	EndIf
	Return
EndFunc   ;==>_MarksOnOff

Func _MarkTarget()
	Local $objOwnInfo = GetAgentByID(-2)
	Local $objTarget = GetAgentByID(-1)

	If DllStructGetData($objOwnInfo, 'Team') <> DllStructGetData($objTarget, 'Team') Then
		$sMarkedTargets &= String(DllStructGetData($objTarget, 'ID')) & ","
		If $bShowTooltips == True Then
			ToolTip(FormatName($objTarget), 0, 0, "Target Info", 1)
		EndIf
	EndIf
	Return
EndFunc   ;==>_MarkTarget

Func FormatName($aAgent)
	If IsDllStruct($aAgent) == 0 Then $aAgent = GetAgentByID($aAgent)
	Local $sString = ""
	Switch DllStructGetData($aAgent, 'Primary')
		Case 0
			$sString &= " "
		Case 1
			$sString &= "W"
		Case 2
			$sString &= "R"
		Case 3
			$sString &= "Mo"
		Case 4
			$sString &= "N"
		Case 5
			$sString &= "Me"
		Case 6
			$sString &= "E"
		Case 7
			$sString &= "A"
		Case 8
			$sString &= "Rt"
		Case 9
			$sString &= "P"
		Case 10
			$sString &= "D"
	EndSwitch

	Switch DllStructGetData($aAgent, 'Secondary')
		Case 0
			$sString &= " "
		Case 1
			$sString &= "/W"
		Case 2
			$sString &= "/R"
		Case 3
			$sString &= "/Mo"
		Case 4
			$sString &= "/N"
		Case 5
			$sString &= "/Me"
		Case 6
			$sString &= "/E"
		Case 7
			$sString &= "/A"
		Case 8
			$sString &= "/Rt"
		Case 9
			$sString &= "/P"
		Case 10
			$sString &= "/D"
		EndSwitch
		$sString &= " - "
		If DllStructGetData($aAgent, 'LoginNumber') > 0 Then
			$sString &= GetPlayerName($aAgent)
		Else
			$sString &= StringReplace(GetAgentName($aAgent), "Corpse of ", "")
		EndIf
	Return $sString
EndFunc   ;==>FormatName

Func GetPlayerNumber($objAgent)
	If IsDllStruct($objAgent) == 0 Then $objAgent = GetAgentByID($objAgent)
	If DllStructGetData($objAgent, 'LoginNumber') > 0 Then
		$sString = GetPlayerName($objAgent)
		$iPosition = StringInStr($sString, "(")
		Return StringTrimLeft($sString, $iPosition-1)
	EndIf
EndFunc   ;==>GetPlayerNumber
#endregion targeting_functions

#region change_state_of_skills
Func _ChangeStateOfSkill1()
	If GUICtrlRead($hUseSkills[1]) == $GUI_CHECKED Then
		$aSkillsChecked[1] = "Off"
		GUICtrlSetState($hUseSkills[1], $GUI_UNCHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 1 DISABLED", 0, 0, "Information", 1)
		EndIf
	ElseIf GUICtrlRead($hUseSkills[1]) == $GUI_UNCHECKED Then
		$aSkillsChecked[1] = "On"
		GUICtrlSetState($hUseSkills[1], $GUI_CHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 1 ENABLED", 0, 0, "Information", 1)
		EndIf
	EndIf
EndFunc   ;==>_ChangeStateOfSkill1

Func _ChangeStateOfSkill2()
	If GUICtrlRead($hUseSkills[2]) == $GUI_CHECKED Then
		$aSkillsChecked[2] = "Off"
		GUICtrlSetState($hUseSkills[2], $GUI_UNCHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 2 DISABLED", 0, 0, "Information", 1)
		EndIf
	ElseIf GUICtrlRead($hUseSkills[2]) == $GUI_UNCHECKED Then
		$aSkillsChecked[2] = "On"
		GUICtrlSetState($hUseSkills[2], $GUI_CHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 2 ENABLED", 0, 0, "Information", 1)
		EndIf
	EndIf
EndFunc   ;==>_ChangeStateOfSkill2

Func _ChangeStateOfSkill3()
	If GUICtrlRead($hUseSkills[3]) == $GUI_CHECKED Then
		$aSkillsChecked[3] = "Off"
		GUICtrlSetState($hUseSkills[3], $GUI_UNCHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 3 DISABLED", 0, 0, "Information", 1)
		EndIf
	ElseIf GUICtrlRead($hUseSkills[3]) == $GUI_UNCHECKED Then
		$aSkillsChecked[3] = "On"
		GUICtrlSetState($hUseSkills[3], $GUI_CHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 3 ENABLED", 0, 0, "Information", 1)
		EndIf
	EndIf
EndFunc   ;==>_ChangeStateOfSkill3

Func _ChangeStateOfSkill4()
	If GUICtrlRead($hUseSkills[4]) == $GUI_CHECKED Then
		$aSkillsChecked[4] = "Off"
		GUICtrlSetState($hUseSkills[4], $GUI_UNCHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 4 DISABLED", 0, 0, "Information", 1)
		EndIf
	ElseIf GUICtrlRead($hUseSkills[4]) == $GUI_UNCHECKED Then
		$aSkillsChecked[4] = "On"
		GUICtrlSetState($hUseSkills[4], $GUI_CHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 4 ENABLED", 0, 0, "Information", 1)
		EndIf
	EndIf
EndFunc   ;==>_ChangeStateOfSkill4

Func _ChangeStateOfSkill5()
	If GUICtrlRead($hUseSkills[5]) == $GUI_CHECKED Then
		$aSkillsChecked[5] = "Off"
		GUICtrlSetState($hUseSkills[5], $GUI_UNCHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 5 DISABLED", 0, 0, "Information", 1)
		EndIf
	ElseIf GUICtrlRead($hUseSkills[5]) == $GUI_UNCHECKED Then
		$aSkillsChecked[5] = "On"
		GUICtrlSetState($hUseSkills[5], $GUI_CHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 5 ENABLED", 0, 0, "Information", 1)
		EndIf
	EndIf
EndFunc   ;==>_ChangeStateOfSkill5

Func _ChangeStateOfSkill6()
	If GUICtrlRead($hUseSkills[6]) == $GUI_CHECKED Then
		$aSkillsChecked[6] = "Off"
		GUICtrlSetState($hUseSkills[6], $GUI_UNCHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 6 DISABLED", 0, 0, "Information", 1)
		EndIf
	ElseIf GUICtrlRead($hUseSkills[6]) == $GUI_UNCHECKED Then
		$aSkillsChecked[6] = "On"
		GUICtrlSetState($hUseSkills[6], $GUI_CHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 6 ENABLED", 0, 0, "Information", 1)
		EndIf
	EndIf
EndFunc   ;==>_ChangeStateOfSkill6

Func _ChangeStateOfSkill7()
	If GUICtrlRead($hUseSkills[7]) == $GUI_CHECKED Then
		$aSkillsChecked[7] = "Off"
		GUICtrlSetState($hUseSkills[7], $GUI_UNCHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 7 DISABLED", 0, 0, "Information", 1)
		EndIf
	ElseIf GUICtrlRead($hUseSkills[7]) == $GUI_UNCHECKED Then
		$aSkillsChecked[7] = "On"
		GUICtrlSetState($hUseSkills[7], $GUI_CHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 7 ENABLED", 0, 0, "Information", 1)
		EndIf
	EndIf
EndFunc   ;==>_ChangeStateOfSkill7

Func _ChangeStateOfSkill8()
	If GUICtrlRead($hUseSkills[8]) == $GUI_CHECKED Then
		$aSkillsChecked[8] = "Off"
		GUICtrlSetState($hUseSkills[8], $GUI_UNCHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 8 DISABLED", 0, 0, "Information", 1)
		EndIf
	ElseIf GUICtrlRead($hUseSkills[8]) == $GUI_UNCHECKED Then
		$aSkillsChecked[8] = "On"
		GUICtrlSetState($hUseSkills[8], $GUI_CHECKED)
		If $bShowTooltips == True Then
			ToolTip("SKILL 8 ENABLED", 0, 0, "Information", 1)
		EndIf
	EndIf
EndFunc   ;==>_ChangeStateOfSkill8
#endregion change_state_of_skills


Func _PauseOnOff()
	$bInterruptingPaused = Not $bInterruptingPaused
	If $bInterruptingPaused == True Then
		If $bShowTooltips == True Then
			ToolTip("PAUSED", 0, 0, "Information", 1)
		EndIf
	ElseIf $bInterruptingPaused == False Then
		If $bShowTooltips == True Then
			ToolTip("UNPAUSED", 0, 0, "Information", 1)
		EndIf
	EndIf
EndFunc   ;==>_PauseOnOff

Func _AntiRuptOnOff()
	$bAntiRuptEnabled = Not $bAntiRuptEnabled
	If $bAntiRuptEnabled == True Then
		If $bShowTooltips == True Then
			ToolTip("ANTI RUPT MODE ENABLED", 0, 0, "Information", 1)
		EndIf
	ElseIf $bAntiRuptEnabled == False Then
		If $bShowTooltips == True Then
			ToolTip("ANTI RUPT MODE DISABLED", 0, 0, "Information", 1)
		EndIf
	EndIf
EndFunc   ;==>_AntiRuptOnOff

Func _RuptEverythingOnOff()
	$bRuptEverythingEnabled = Not $bRuptEverythingEnabled
	If $bRuptEverythingEnabled == True Then
		If $bShowTooltips == True Then
			ToolTip("RUPT EVERYTHING MODE ENABLED", 0, 0, "Information", 1)
		EndIf
	ElseIf $bRuptEverythingEnabled == False Then
		If $bShowTooltips == True Then
			ToolTip("RUPT EVERYTHING MODE DISABLED", 0, 0, "Information", 1)
		EndIf
	EndIf
EndFunc   ;==>_RuptEverythingOnOff

Func GetTeam($aTeam)
	Local $lTeamNumber = $aTeam
	Local $lTeam[1][3]
	Local $lTeamSmall[1] = [0]
	Local $lAgent
	$lTeam[0][0] = 0
	$lTeam[0][1] = $lTeamNumber
	$lTeam[0][2] = 0
	If $lTeamNumber == 0 Then Return $lTeamSmall
	For $i = 1 To GetMaxAgents()
		$lAgent = GetAgentByID($i)
		If DllStructGetData($lAgent, 'ID') == 0 Then ContinueLoop
		If Not GetIsDead($lAgent) And GetIsLiving($lAgent) And DllStructGetData($lAgent, 'Team') == $lTeamNumber And (DllStructGetData($lAgent, 'LoginNumber') <> 0 Or StringRight(GetAgentName($lAgent), 9) == "Henchman]") Then
			$lTeam[0][0] += 1
			ReDim $lTeam[$lTeam[0][0]+1][3]
			$lTeam[$lTeam[0][0]][0] = DllStructGetData($lAgent, 'id')
			$lTeam[$lTeam[0][0]][1] = DllStructGetData($lAgent, 'PlayerNumber')
			$lTeam[$lTeam[0][0]][2] = FormatName($lAgent)
		EndIf
	Next
	_ArraySort($lTeam, 0, 1, 0, 1)
	Return $lTeam
EndFunc   ;==>GetTeam

Func _ShowEnemyParty()
	If $bEnabled == True Then
		Local $objOwnInfo = GetAgentByID(-2)
		Local $aEnemyPartyInfo
		Local $sString
		If DllStructGetData($objOwnInfo, 'Team') == 1 Then
			$aEnemyPartyInfo = GetTeam(2)
		ElseIf DllStructGetData($objOwnInfo, 'Team') == 2 Then
			$aEnemyPartyInfo = GetTeam(1)
		Else
			Return
		EndIf
		For $i = 1 To $aEnemyPartyInfo[0][0] Step 1
			$sString &= $aEnemyPartyInfo[$i][2] & @CRLF
		Next
		ToolTip($sString, 0, 0, "Enemy Party Info", 1)
	EndIf
	Return
EndFunc   ;==>_ShowEnemyParty

Func _Reset()
	ToolTip("")
EndFunc   ;==>_Reset

Func HideGUI()
	GUISetState(@SW_HIDE)
EndFunc   ;==>HideGUI

Func ShowGUI()
	GUISetState(@SW_SHOW)
EndFunc   ;==>ShowGUI

Func HideTooltips()
	$bShowTooltips = False
	ToolTip("")
EndFunc   ;==>HideTooltips

Func ShowTooltips()
	$bShowTooltips = True
	ToolTip("Tooltips ENABLED")
EndFunc   ;==>ShowTooltips

GUISetBkColor(0x999999)
UpdateSkillSets()
UpdateSkills()
SetEvent("", "", "", "", "Load")
GUISetState(True, $hGUI)
While 1
	If $bCasting == True Then
		$fCastRemaining = $fMyActivation + $fMyAftercast - TimerDiff($fMyTimer)
		If $fCastRemaining <= 0 Then
			$fCastRemaining = 0
			$bCasting = False
		EndIf
	EndIf
	If $bDiversion == True Then
		If TimerDiff($fDiversionTimer) > 5750 Then
			$bDiversion = False
			$iDiversionedID = 0
			$fDiversionTimer = 0
		EndIf
	EndIf
	Sleep(20)
WEnd