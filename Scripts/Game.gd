extends Node2D

var dificuldade = "hard"
var changeColor = true
var turno = 1
var ButtonDificuldade= false

func cleanMatriz():
	return [[" "," "," "],
			[" "," "," "],
			[" "," "," "]]
			
var matriz = cleanMatriz()

func changeImages():
	for i in range(matriz.size()):
		for j in range(matriz[i].size()):
			#0
			var path = ""
			path+="AS"
			path+=str(i)
			path+="x"
			path+=str(j)
			if (matriz[i][j]=="o"):
				get_node(path).animation="O"
			#X
			elif (matriz[i][j]=="x"):
				if (dificuldade=="hard"):
					get_node(path).animation="X"
				elif (dificuldade=="medium"):
					get_node(path).animation="X_M"
				elif (dificuldade=="easy"):
					get_node(path).animation="X_E"
			#Vazio
			elif (matriz[i][j]==" "):
				get_node(path).animation="Vazio"

func _ready() -> void:
	start()
	
func _process(delta: float) -> void:
	if (turno>2 and ButtonDificuldade):
		ButtonVisibility()
	if (changeColor):
		changeColor = false
		changeColorButton()

func changeColorButton():
		if (dificuldade== "easy"):
			get_parent().get_node("Button_easy").get("custom_styles/normal").set("bg_color",Color("3b00ff00"))
			get_parent().get_node("Button_medium").get("custom_styles/normal").set("bg_color",Color("3b999999"))
			get_parent().get_node("Button_hard").get("custom_styles/normal").set("bg_color",Color("3b999999"))
		elif (dificuldade== "medium"):
			get_parent().get_node("Button_easy").get("custom_styles/normal").set("bg_color",Color("3b999999"))
			get_parent().get_node("Button_medium").get("custom_styles/normal").set("bg_color",Color("3bffff00"))
			get_parent().get_node("Button_hard").get("custom_styles/normal").set("bg_color",Color("3b999999"))
		elif (dificuldade== "hard"):
			get_parent().get_node("Button_easy").get("custom_styles/normal").set("bg_color",Color("3b999999"))
			get_parent().get_node("Button_medium").get("custom_styles/normal").set("bg_color",Color("3b999999"))
			get_parent().get_node("Button_hard").get("custom_styles/normal").set("bg_color",Color("3bff0000"))
		
func ButtonVisibility():
	get_parent().get_node("Button_easy").visible=!ButtonDificuldade
	get_parent().get_node("Button_medium").visible=!ButtonDificuldade
	get_parent().get_node("Button_hard").visible=!ButtonDificuldade
	ButtonDificuldade=!ButtonDificuldade
	
#Jogada da maquina	
func _on_Maquina_timeout() -> void:
	$BlasterSound.play()
	var p
	if (dificuldade=="easy"||turno==1):
		p =random()
	elif (dificuldade=="medium"):
		var n = intRandom(0,10)+1
		if (n>3):
			print("Jogou miniMax no medio")
			p =miniMax()
		else:
			print("Jogou Random no medio")
			p =random()
	elif (dificuldade=="hard"):
		p =miniMax()
	matriz[p.x][p.y]="x"
	turno+=1
	print("Maquina joga em: ",p.x,"x",p.y)
	changeImages()
	if (isGameFinish(matriz,false)):
		if (dificuldade=="hard"):
			$FimDeJogo.wait_time=3
			$Hard_Win.play()
		elif (dificuldade=="medium"):
			$FimDeJogo.wait_time=1.5
			$Medium_Win.play()
		elif (dificuldade=="easy"):
			$FimDeJogo.wait_time=2
			$Easy_Win.play()
		
		$FimDeJogo.start()
	else:
		$Estado.text="Vez do Jogador"
		
func miniMax():
	var vitorias = []
	var empates = []
	var derrotas = []
	for i in range(matriz.size()):
		for j in range(matriz[i].size()):
			if (matriz[i][j]==" "):
				var nm = matriz.duplicate(true)
				nm[i][j]="x"
				var result = isGameFinish(nm,true)
				if (String(result) == "1"):
					return {"x":i,"y":j}
				elif (String(result) == "0"):
					return {"x":i,"y":j}
				elif (result == "continua"):
					var v =miniMaxR(nm,false)
					if (v==1):
						vitorias.append({"x":i,"y":j})
					elif (v==0):
						empates.append({"x":i,"y":j})
					elif (v==-1):
						derrotas.append({"x":i,"y":j})
	if (vitorias.size()>0):
		var n = intRandom(0,vitorias.size())
		return vitorias[n]
	elif (empates.size()>0):
		var n = intRandom(0,empates.size())
		return empates[n]
	else:
		var n = intRandom(0,derrotas.size())
		return derrotas[n]

func miniMaxR(m,Max):
	var melhorJogadaValue
	if (Max):
		melhorJogadaValue=-1
	else:
		melhorJogadaValue=1
	for i in range(m.size()):
		for j in range(m[i].size()):
			if (m[i][j]==" "):
				var nm = m.duplicate(true)
				if (Max):
					nm[i][j]="x"
				else:
					nm[i][j]="o"
				var result = isGameFinish(nm,true)
				if (String(result)=="continua"):
						result = miniMaxR(nm,!Max)
				if(Max):
					if (result==1):
						return result
					elif (result>melhorJogadaValue):
							melhorJogadaValue= result
				else:
					if (result==-1):
						return result
					elif (result<melhorJogadaValue):
							melhorJogadaValue= result
	return melhorJogadaValue

func random():
	var x = intRandom(0,3)
	var y = intRandom(0,3)
	while (matriz[x][y]!=" "):
		x = intRandom(0,3)
		y = intRandom(0,3)
	return {"x":x,"y":y}

func _on_FimDeJogo_timeout() -> void:
	start()

func intRandom(minV,maxV):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return int (rng.randf_range(minV, maxV))

"""
Reseta animacao de video
func resetSabers():
	var video_file = "res://Assets/RedSaber.webm"
	var sfx = load(video_file) 
	get_parent().get_node("RedSaber").stream = sfx
	var video_file2 = "res://Assets/BlueSaber.webm"
	var sfx2 = load(video_file2) 
	get_parent().get_node("BlueSaber").stream = sfx2
	get_parent().get_node("RedSaber").visible=false
	get_parent().get_node("BlueSaber").visible=false
"""


func start():
	print("Inicio da partida: ")
	get_parent().get_node("SaberAnimation").visible=false
	#$VaderBreathing.stop()
	ButtonVisibility()
	turno = 1
	matriz = cleanMatriz()
	changeImages()
	var i = intRandom(0,2)
	if (i==0):
		$Estado.text="Vez do Jogador"
	else:
		maquinaStart()
		
func maquinaStart():
	$Estado.text="Vez da Maquina"
	#if(!$VaderBreathing.playing):
	#	$VaderBreathing.play()
	#	$VaderBreathing/Stop.start()
	#$BlasterSound.play()
	$Maquina.start()

func isGameFinish(matriz,miniMax):
	#Linhas
	if (matriz[0][0]==matriz[0][1] and matriz[0][1]==matriz[0][2] and matriz[0][0]!=" "):
		if(miniMax):
			if (matriz[0][0]=="x"):
				return 1
			elif(matriz[0][0]=="o"):
				return -1
		else:	
			print ("Vitoria: ",matriz[0][0])
			$Estado.text="Vitoria do " + matriz[0][0]
			print("Vitoria de linha 1")
			winAnimation(matriz[0][0],"l1")
			return true
	elif (matriz[1][0]==matriz[1][1] and matriz[1][1]==matriz[1][2] and matriz[1][0]!=" "):
		if(miniMax):
			if (matriz[1][0]=="x"):
				return 1
			elif(matriz[1][0]=="o"):
				return -1
		else:
			print ("Vitoria: ",matriz[1][0])
			$Estado.text="Vitoria do " + matriz[1][0]
			print("Vitoria de linha 2")
			winAnimation(matriz[1][0],"l2")
			return true
	elif (matriz[2][0]==matriz[2][1] and matriz[2][1]==matriz[2][2]and matriz[2][0]!=" "):
		if(miniMax):
			if (matriz[2][0]=="x"):
				return 1
			elif(matriz[2][0]=="o"):
				return -1
		else:
			print ("Vitoria: ",matriz[2][0])
			$Estado.text="Vitoria do " + matriz[2][0]
			print("Vitoria de linha 3")
			winAnimation(matriz[2][0],"l3")
			return true
	#Colunas
	elif (matriz[0][0]==matriz[1][0] and matriz[1][0]==matriz[2][0] and matriz[0][0]!=" "):
		if(miniMax):
			if (matriz[0][0]=="x"):
				return 1
			elif(matriz[0][0]=="o"):
				return -1
		else:
			print ("Vitoria: ",matriz[0][0])
			$Estado.text="Vitoria do " + matriz[0][0]
			print("Vitoria de coluna 1")
			winAnimation(matriz[0][0],"c1")
			return true
	elif (matriz[0][1]==matriz[1][1] and matriz[1][1]==matriz[2][1] and matriz[0][1]!=" "):
		if(miniMax):
			if (matriz[0][1]=="x"):
				return 1
			elif(matriz[0][1]=="o"):
				return -1
		else:
			print ("Vitoria: ",matriz[0][1])
			$Estado.text="Vitoria do " + matriz[0][1]
			print("Vitoria de coluna 2")
			winAnimation(matriz[0][1],"c2")
			return true
	elif (matriz[0][2]==matriz[1][2] and matriz[1][2]==matriz[2][2] and matriz[0][2]!=" "):
		if(miniMax):
			if (matriz[0][2]=="x"):
				return 1
			elif(matriz[0][2]=="o"):
				return -1
		else:
			print ("Vitoria: ",matriz[0][2])
			$Estado.text="Vitoria do " + matriz[0][2]
			print("Vitoria de coluna 3")
			winAnimation(matriz[0][2],"c3")
			return true		
	#Diagonais
	elif (matriz[0][0]==matriz[1][1] and matriz[1][1]==matriz[2][2] and matriz[0][0]!=" "):
		if(miniMax):
			if (matriz[0][0]=="x"):
				return 1
			elif(matriz[0][0]=="o"):
				return -1
		else:
			print ("Vitoria: ",matriz[0][0])
			$Estado.text="Vitoria do " + matriz[0][0]
			print("Vitoria de diagonal 1")
			winAnimation(matriz[0][0],"d1")
			return true
	elif (matriz[2][0]==matriz[1][1] and matriz[1][1]==matriz[0][2] and matriz[2][0]!=" "):
		if(miniMax):
			if (matriz[2][0]=="x"):
				return 1
			elif(matriz[2][0]=="o"):
				return -1	
		else:
			print ("Vitoria: ",matriz[2][0])
			$Estado.text="Vitoria do " + matriz[2][0]
			print("Vitoria de diagonal 2")
			winAnimation(matriz[2][0],"d2")
			return true		
	#Empate
	var empate = true
	for i in range(matriz.size()):
		for j in range(matriz[i].size()):
			if (matriz[i][j]==" "):
				empate=false
	if (empate):
		if(miniMax):
			return 0
		else:
			print("empate")
			$Estado.text="Empate"
			return true
	#Jogo continua
	if(miniMax):
		return "continua"
	else:
		return false

func printarMatriz(matriz):
	for i in range(matriz.size()):
		var line=""
		for j in range(matriz[i].size()):
			if (matriz[i][j]== " "):
				line += " -"
			else: 
				line += " "+matriz[i][j] 
		print(line)

func isFree(x,y):
	if (matriz[x][y]==" "):
		$BlasterSound.play()
		matriz[x][y]="o"
		turno+=1
		print("Jogador joga em: ",x,"x",y)
		changeImages()
		if (isGameFinish(matriz,false)):
			$Player_Win.play()
			$FimDeJogo.wait_time=1.5
			$FimDeJogo.start()
		else:
			maquinaStart()
	else:
		print("Jogada nao permitida")

func winAnimation(vencedor,tipo):
	var typeSaber
	if (vencedor=="x"):
		typeSaber="RedSaber"
	else:
		typeSaber="BlueSaber"
	#Coluna 1	
	if(tipo=="c1"):
		wAPlayer(480,580,0.234,0.872,0,typeSaber)
	#Coluna 2
	elif(tipo=="c2"):
		wAPlayer(710,580,0.234,0.872,0,typeSaber)
	#Coluna 3
	elif(tipo=="c3"):
		wAPlayer(940,580,0.234,0.872,0,typeSaber)
	#Linha 1
	elif(tipo=="l1"):
	 wAPlayer(710,401,0.234,1.152,90,typeSaber)
	#Linha 2
	elif(tipo=="l2"):
	 wAPlayer(710,571,0.234,1.152,90,typeSaber)
	#Linha 3
	elif(tipo=="l3"):
	 wAPlayer(710,741,0.234,1.152,90,typeSaber)
	#Diagonal 1
	elif(tipo=="d1"):
	 wAPlayer(710,580,0.234,1.43,127,typeSaber)
	#Diagonal 2
	elif(tipo=="d2"):
	  wAPlayer(709,586,0.234,1.416,53.1,typeSaber)
	
func wAPlayer(x,y,scaleX,scaleY,Rotation,typeSaber):
	get_parent().get_node("SaberAnimation").position.x = x
	get_parent().get_node("SaberAnimation").position.y = y
	get_parent().get_node("SaberAnimation").scale.x=scaleX
	get_parent().get_node("SaberAnimation").scale.y=scaleY
	get_parent().get_node("SaberAnimation").rotation_degrees=Rotation
	get_parent().get_node("SaberAnimation").animation=typeSaber
	
	get_parent().get_node("SaberAnimation").frame=1
	if (typeSaber=="RedSaber"):
		$XWinSound.play()
		get_node("XWinSound/Stop").start()
	else:
		$OWinSound.play()
		get_node("OWinSound/Stop").start()
	
	get_parent().get_node("SaberAnimation").play()
	get_parent().get_node("SaberAnimation").visible=true
	

func _on_Button0x0_pressed() -> void:
	#print("Button 0x0 pressed!")

	if ($Estado.text=="Vez do Jogador"):
		isFree(0,0)		

func _on_Button0x1_pressed() -> void:
	#print("Button 0x1 pressed!")
	if ($Estado.text=="Vez do Jogador"):
		isFree(0,1)	

func _on_Button0x2_pressed() -> void:
	#print("Button 0x2 pressed!")
	if ($Estado.text=="Vez do Jogador"):
		isFree(0,2)	
	
func _on_Button1x0_pressed() -> void:
	#print("Button 1x0 pressed!")
	if ($Estado.text=="Vez do Jogador"):
		isFree(1,0)	

func _on_Button1x1_pressed() -> void:
	#print("Button 1x1 pressed!")
	if ($Estado.text=="Vez do Jogador"):
		isFree(1,1)	

func _on_Button1x2_pressed() -> void:
	#print("Button 1x2 pressed!")
	if ($Estado.text=="Vez do Jogador"):
		isFree(1,2)	

func _on_Button2x0_pressed() -> void:
	#print("Button 2x0 pressed!")
	if ($Estado.text=="Vez do Jogador"):
		isFree(2,0)	

func _on_Button2x1_pressed() -> void:
	#print("Button 2x1 pressed!")
	if ($Estado.text=="Vez do Jogador"):
		isFree(2,1)	

func _on_Button2x2_pressed() -> void:
	#print("Button 2x2 pressed!")
	if ($Estado.text=="Vez do Jogador"):
		isFree(2,2)	

func _on_Button_easy_pressed() -> void:
	dificuldade="easy"
	changeColor=true
	print(dificuldade)
	changeImages()

func _on_Button_medium_pressed() -> void:
	dificuldade= "medium"
	changeColor=true
	print(dificuldade)
	changeImages()

func _on_Button_hard_pressed() -> void:
	dificuldade= "hard"
	changeColor=true
	print(dificuldade)
	changeImages()


func _on_Teste_pressed() -> void:
	wAPlayer(770,490,240,550,90,"RedSaber")

func _on_AnimationSaberToStartPosition_timeout() -> void:
		get_parent().get_node("RedSaber").stop()
		get_parent().get_node("BlueSaber").stop()
		get_parent().get_node("RedSaber").volume_db=0
		get_parent().get_node("BlueSaber").volume_db=0


func _on_TesteTimer_timeout() -> void:
	return
	
	var tipo = "d2"
	var typeSaber = "RedSaber"
	if(tipo=="c1"):
		wAPlayer(480,580,0.234,0.872,0,typeSaber)
	#Coluna 2
	elif(tipo=="c2"):
		wAPlayer(710,580,0.234,0.872,0,typeSaber)
	#Coluna 3
	elif(tipo=="c3"):
		wAPlayer(940,580,0.234,0.872,0,typeSaber)
	#Linha 1
	elif(tipo=="l1"):
	 wAPlayer(710,401,0.234,1.152,90,typeSaber)
	#Linha 2
	elif(tipo=="l2"):
	 wAPlayer(710,571,0.234,1.152,90,typeSaber)
	#Linha 3
	elif(tipo=="l3"):
	 wAPlayer(710,741,0.234,1.152,90,typeSaber)
	#Diagonal 1
	elif(tipo=="d1"):
	 wAPlayer(710,580,0.234,1.43,127,typeSaber)
	#Diagonal 2
	elif(tipo=="d2"):
	  wAPlayer(709,586,0.234,1.416,53.1,typeSaber)
	

