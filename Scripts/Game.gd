extends Node2D



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
	var x = int(rand_range(0,3))
	var y = int(rand_range(0,3))
	while (matriz[x][y]!=" "):
		x = int(rand_range(0,3))
		y = int(rand_range(0,3))
	matriz[x][y]="x"
	print("Maquina joga em: ",x,"x",y)
	changeImages()
	if (isGameFinish(matriz)):
		$FimDeJogo.start()
	else:
		$Estado.text="Vez do Jogador"

func _on_FimDeJogo_timeout() -> void:
	start()
		

func start():
	print("Inicio da partida: ")
	matriz = cleanMatriz()
	changeImages()

	var i = int(rand_range(0,2))
	if (i==0):
		$Estado.text="Vez do Jogador"
	else:
		$Estado.text="Vez da Maquina"
		$Maquina.start()


func isGameFinish(matriz):
	#Linhas
	if (matriz[0][0]==matriz[0][1] and matriz[0][1]==matriz[0][2] and matriz[0][0]!=" "):
		print ("Vitoria: ",matriz[0][0])
	
		$Estado.text="Vitoria do " + matriz[0][0]
		print("Vitoria de linha 1")
		return true
	elif (matriz[1][0]==matriz[1][1] and matriz[1][1]==matriz[1][2] and matriz[1][0]!=" "):
		print ("Vitoria: ",matriz[1][0])
		
		$Estado.text="Vitoria do " + matriz[1][0]
		print("Vitoria de linha 2")
		return true
	elif (matriz[2][0]==matriz[2][1] and matriz[2][1]==matriz[2][2]and matriz[2][0]!=" "):
		print ("Vitoria: ",matriz[2][0])
		
		$Estado.text="Vitoria do " + matriz[2][0]
		print("Vitoria de linha 3")
		return true
	#Colunas
	elif (matriz[0][0]==matriz[1][0] and matriz[1][0]==matriz[2][0] and matriz[0][0]!=" "):
		print ("Vitoria: ",matriz[0][0])
		
		$Estado.text="Vitoria do " + matriz[0][0]
		print("Vitoria de coluna 1")
		return true
	elif (matriz[0][1]==matriz[1][1] and matriz[1][1]==matriz[2][1] and matriz[0][1]!=" "):
		print ("Vitoria: ",matriz[0][1])
		$Estado.text="Vitoria do " + matriz[0][1]
		print("Vitoria de coluna 2")
		return true
	elif (matriz[0][2]==matriz[1][2] and matriz[1][2]==matriz[2][2] and matriz[0][2]!=" "):
		print ("Vitoria: ",matriz[0][2])
		$Estado.text="Vitoria do " + matriz[0][2]
		print("Vitoria de coluna 3")
		return true		
	#Diagonais
	elif (matriz[0][0]==matriz[1][1] and matriz[1][1]==matriz[2][2] and matriz[0][0]!=" "):
		print ("Vitoria: ",matriz[0][0])
		$Estado.text="Vitoria do " + matriz[0][0]
		print("Vitoria de diagonal 1")
		return true
	elif (matriz[2][0]==matriz[1][1] and matriz[1][1]==matriz[0][2] and matriz[2][0]!=" "):
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
		print("empate")
		$Estado.text="Empate"
		return true
	
	#Jogo continua
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
		print("Jogador joga em: ",x,"x",y)
		changeImages()
		if (isGameFinish(matriz)):
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

