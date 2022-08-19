extends Node2D

var dificuldade = "hard"
var turno = 1

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
				get_node(path).animation="X"
			#Vazio
			elif (matriz[i][j]==" "):
				get_node(path).animation="Vazio"

func _ready() -> void:
	start()
	
#Jogada da maquina	
func _on_Maquina_timeout() -> void:
	var p
	if (dificuldade=="easy"||turno==1):
		p =random()
	elif (dificuldade=="hard"):
		p =miniMax()
	matriz[p.x][p.y]="x"
	turno+=1
	print("Maquina joga em: ",p.x,"x",p.y)
	changeImages()
	if (isGameFinish(matriz,false)):
		$FimDeJogo.start()
	else:
		$Estado.text="Vez do Jogador"
		
func miniMax():
	var vitorias = []
	var empates = []
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
	if (vitorias.size()>0):
		var n = intRandom(0,vitorias.size())
		return vitorias[n]
	else:
		var n = intRandom(0,empates.size())
		return empates[n]

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

func start():
	print("Inicio da partida: ")
	turno = 1
	matriz = cleanMatriz()
	changeImages()
	var i = intRandom(0,2)
	if (i==0):
		$Estado.text="Vez do Jogador"
	else:
		$Estado.text="Vez da Maquina"
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
		matriz[x][y]="o"
		turno+=1
		print("Jogador joga em: ",x,"x",y)
		changeImages()
		if (isGameFinish(matriz,false)):
			$FimDeJogo.start()
		else:
			$Estado.text="Vez da Maquina"
			$Maquina.start()
	else:
		print("Jogada nao permitida")
	
		
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

