/*
 Hello world!
*/

#include "eth_util.angelscript"

vector2 SCREEN_SIZE = GetScreenSize();
int space = 1000;
float speed = 1.0f;
int lastSpawn = 0;
int score = 2100;
int endTime = 0;
bool spawnF = false;
int inputCount;
int lastShot = 0;
int health = 100;
int SpeedConstant = 1;
int healthUpgrade = 100;
int powered = 100;
int circleBomb = 100;

bool healthUnlocked = false;
bool poweredUnlocked = false;
bool circleUnlocked = false;

bool bossSpawn = false;
int minionSpawn;

int menuInt = 1;
int Mid;

void main()
{
	LoadScene("empty", "menu", "menuRun");

	// Prefer setting window properties in the app.enml file
	// SetWindowProperties("Ethanon Engine", 1024, 768, true, true, PF32BIT);
}

void menu(){
	Mid = AddEntity("menu.ent",vector3(400,300,0));
	menuInt = 1;
	}

void menuRun(){
	ETHInput@ input = GetInputHandle();
	if(input.GetKeyState(K_UP) == KS_HIT){
		if(menuInt <= 1)menuInt = 3;
		else{menuInt--;}
		SeekEntity(Mid).SetSprite("menu" + menuInt + ".png");
		}
	if(input.GetKeyState(K_DOWN) == KS_HIT){
		if(menuInt >= 3)menuInt = 1;
		else{menuInt++;}
		SeekEntity(Mid).SetSprite("menu" + menuInt + ".png");
		}
	if(input.GetKeyState(K_ENTER) == KS_HIT){
		if(menuInt == 1){
			LoadScene("empty", "Start", "Run");
			}
		if(menuInt == 2){
			LoadScene("empty", "ach", "back");
			}
		if(menuInt == 3){
			Exit();
			}
		}
	}

void Start(){
	//AddEntity("exit.ent", vector3(SCREEN_SIZE/2,0));
	int id = AddEntity("robot.ent", vector3(SCREEN_SIZE/2,0));
	SeekEntity(id).SetScale(vector2(0.2f,0.2f));
	}
	
void Run(){
	print("" + rand(1));
	DrawText(vector2(0,12), "health: " + health, "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	if(score >= 200)DrawText(vector2(0,24), "Healthkit: " + healthUpgrade + "%", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	if(score >= 300)DrawText(vector2(0,36), "PoweredShot: " + powered + "%", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	if(score >= 400)DrawText(vector2(0,48), "CircleBomb: " + circleBomb + "%", "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	if(score >= 00)DrawText(vector2(0,0), "score: " + score, "Verdana14_shadow.fnt", ARGB(250,255,255,255));
	if(score >= 200 and healthUnlocked == false){
		DrawFadingText(vector2(SCREEN_SIZE.x - 390, 0), "Health Restore Unlocked. Press Q to Use.", "Verdana20.fnt", ARGB(250,255,255,255), 4000);
		healthUnlocked = true;
		}
	if(score >= 400 and poweredUnlocked == false){
		DrawFadingText(vector2(SCREEN_SIZE.x - 370, 0), "PoweredShot Unlocked. Will AutoFire.", "Verdana20.fnt", ARGB(250,255,255,255), 4000);
		poweredUnlocked = true;
		}
	if(score >= 600 and circleUnlocked == false){
		DrawFadingText(vector2(SCREEN_SIZE.x - 370, 0), "CircleBomb Unlocked. Press E to Use.", "Verdana20.fnt", ARGB(250,255,255,255), 4000);
		circleUnlocked = true;
		}
	if(GetTime() - lastSpawn > space){
		int tempX = rand(-2000, 2000);
		int tempY = rand(-2000, 2000);
		lastSpawn = GetTime();
		space = rand(500 - score/10,1000 - score/10) + 1000/(score/10 + 1);
		if(space < 50)space = 50;
		while((tempX < SCREEN_SIZE.x and tempX > 0) and (tempY < SCREEN_SIZE.y and tempY > 0)){
			tempX = rand(-2000,2000);
			tempY = rand(-2000,2000);
			}
		int type = DetermineEnemyType();
		if(type != -1){
			int id = AddEntity("enemy.ent",vector3(tempX,tempY,0));
			SeekEntity(id).SetInt("type",type);
			SeekEntity(id).SetScale(vector2(0.2f,0.2f));
			if(type != 0)SeekEntity(id).SetSprite("enemy" + type + "_ship.png");
			SeekEntity(id).SetInt("health",determineHealth(type));
			}
		if(score >= 2000){
			ETHEntityArray temp;
			GetEntityArray("enemy.ent",temp);
			if(temp.Size() == 0 and bossSpawn == false){
				spawnBoss();
				}
			}
	if(GetTime() - endTime > 2000 and endTime != 0) Exit();
	if(health <= 0)Exit();
	}
}

void spawnBoss(){
	if(SeekEntity("boss.ent") is null){
		int id = AddEntity("boss.ent",vector3(SCREEN_SIZE.x/2,-400,0));
		SeekEntity(id).SetInt("health",100);
		bossSpawn = true;
		}
}

void ETHCallback_boss(ETHEntity@ obj){
	if(obj.GetPositionY() < 0)obj.AddToPositionY(1);
	if(obj.GetPositionY() >= 0){
		ETHEntityArray temp;
		GetEntityArray("bullet.ent", temp);
		for(int i = 0; i < temp.Size(); i++){
			if(distance(obj.GetPositionXY(),temp[i].GetPositionXY()) < 300){
				if(temp[i].GetInt("powered") == 1)obj.AddToInt("health",-5);
				else{obj.AddToInt("health",-1);}
				DeleteEntity(temp[i]);
				}
			}
		temp.Clear();
		DrawText(vector2(SCREEN_SIZE.x/2 - 20,0), 100*obj.GetInt("health") + "", "Verdana20_shadow.fnt", ARGB(250,0,0,0));
		if(obj.GetInt("health") > 0 and GetTime() - minionSpawn > 2000){
			minionSpawn = GetTime();
			int id = AddEntity("enemy.ent",vector3(-100,SCREEN_SIZE.y/2 + rand(-100,100),0));
			int type = rand(3);
			SeekEntity(id).SetInt("type",type);
			SeekEntity(id).SetScale(vector2(0.2f,0.2f));
			if(type != 0)SeekEntity(id).SetSprite("enemy" + type + "_ship.png");
			SeekEntity(id).SetInt("health",determineHealth(type));
			id = AddEntity("enemy.ent",vector3(SCREEN_SIZE.x + 100,SCREEN_SIZE.y/2 + rand(-100,100),0));
			type = rand(3);
			SeekEntity(id).SetInt("type",type);
			SeekEntity(id).SetScale(vector2(0.2f,0.2f));
			if(type != 0)SeekEntity(id).SetSprite("enemy" + type + "_ship.png");
			SeekEntity(id).SetInt("health",determineHealth(type));
			}
		}
}

int determineHealth(int x){
	if(x == 0)return 1;
	if(x == 1)return 2;
	if(x == 2)return 4;
	if(x == 3)return 5;
	else{return 0;}
	}

int DetermineEnemyType(){
	if(score < 200){
		return 0;
		}
	else if(score >= 200 and score < 600){
		return rand(1);
		}
	else if(score >= 600 and score < 1000){
		return rand(2);
		}
	else if(score >= 1000 and score < 2000){
		return rand(2) + 1;
		}
	else{return -1;}
	}

void ETHCallback_robot(ETHEntity@ thisEntity){

ETHInput@ input = GetInputHandle();
	inputCount = 0;
	int inputX = 0;
	int inputY = 0;
	if(input.KeyDown(K_W) and thisEntity.GetPositionY() > 40){
			if(SeekEntity("boss.ent") is null or thisEntity.GetPositionY()>300)thisEntity.AddToPositionY(-2);
			inputX += 1;
		}
	if(input.KeyDown(K_S) and thisEntity.GetPositionY() < SCREEN_SIZE.y - 40){
		thisEntity.AddToPositionY(2);
		inputX -= 1;
		}
	if(input.KeyDown(K_A) and thisEntity.GetPositionX() > 40){
		thisEntity.AddToPositionX(-2);
		inputY += 1;
		}
	if(input.KeyDown(K_D) and thisEntity.GetPositionX() < SCREEN_SIZE.x - 40){
		thisEntity.AddToPositionX(2);
		inputY -=1;
		}
	if(input.KeyDown(K_SPACE) and GetTime() - lastShot > 200){
		int id = AddEntity("bullet.ent",thisEntity.GetPosition());
		SeekEntity(id).SetInt("X",returnXAngle(thisEntity.GetAngle()));
		SeekEntity(id).SetInt("Y", returnYAngle(thisEntity.GetAngle()));
		if(powered == 100 and score >= 400){
			SeekEntity(id).SetInt("powered", 1);
			powered = -1;
			SeekEntity(id).SetSprite("power_bullet.png");
			}
			else{
			SeekEntity(id).SetInt("powered", 0);
			}
		lastShot = GetTime();
		}
	if(input.KeyDown(K_Q) and healthUpgrade == 100 and score >= 200){
		health += 50;
		healthUpgrade = -1;
		}
	if(input.KeyDown(K_E) and circleBomb == 100 and score >= 400){
		ETHEntityArray temp;
		GetEntityArray("enemy.ent",temp);
		for(int i = 0; i < temp.Size(); i++){
			if(distance(temp[i].GetPositionXY(),thisEntity.GetPositionXY()) < 100)temp[i].AddToInt("health",-3);
			}
		temp.Clear();
		circleBomb = -1;
		}
	if(healthUpgrade < 100)healthUpgrade += 1;
	if(powered < 100)powered += 1;
	if(circleBomb < 100)circleBomb += 1;
	SetAngle(thisEntity,inputX, inputY);
	if(input.KeyDown(K_ESC))Exit();
	}


void ETHCallback_enemy(ETHEntity@ obj){
	if(obj.GetInt("health") <= 0)DeleteEntity(obj);
	if(distance(obj.GetPositionXY(),SeekEntity("robot.ent").GetPositionXY()) < 10)DeleteEntity(obj);
	else if(distance(obj.GetPositionXY(),SeekEntity("robot.ent").GetPositionXY()) < 20){
		DeleteEntity(obj);
		health -= 10;
		}
	float tempX =SeekEntity("robot.ent").GetPositionX() - obj.GetPositionX();
	float tempY =SeekEntity("robot.ent").GetPositionY() - obj.GetPositionY();
	float dirX = tempX/(abs(tempX) + abs(tempY));
	float dirY = tempY/(abs(tempX) + abs(tempY));
	speed = determineSpeed(obj.GetInt("type"));
	obj.AddToPositionXY(vector2(dirX * speed,dirY* speed));

}

int determineSpeed(int x){
	if(x == 0)return 4;
	if(x == 1)return 5;
	if(x == 2)return 6;
	if(x == 3)return 7;
	else{return 0;}
	}
void ETHCallback_bullet(ETHEntity@ obj){
	ETHEntityArray temp;
	GetEntityArray("enemy.ent", temp);
	obj.AddToPositionXY(vector2(obj.GetInt("X") * 10,obj.GetInt("Y") * 10));
	int tempX = obj.GetPositionX();
	int tempY = obj.GetPositionY();
	if(tempX > SCREEN_SIZE.x or tempX < 0 or tempY < 0 or tempY > SCREEN_SIZE.y)DeleteEntity(obj);
	for(int i = 0; i < temp.Size();i++){
		if(distance(temp[i].GetPositionXY(),obj.GetPositionXY()) < 50){
			if(obj.GetInt("powered") == 1)temp[i].AddToInt("health",-5);
			temp[i].AddToInt("health",-1);
			score += (temp[i].GetInt("type") + 1) * 10;
			temp.Clear();
			DeleteEntity(obj);
			break;
			}
		}
	temp.Clear();
}

void ETHCallback_exit(ETHEntity@ obj){
	obj.AddToPositionXY(vector2(rand(-10,10),rand(-10,10)));
	int tempX = obj.GetPositionX();
	int tempY = obj.GetPositionY();
	if(tempX < 0) obj.SetPositionX(0);
	if(tempX > SCREEN_SIZE.x) obj.SetPositionX(SCREEN_SIZE.x);
	if(tempY < 0) obj.SetPositionY(0);
	if(tempY > SCREEN_SIZE.y) obj.SetPositionY(SCREEN_SIZE.y);
	}
	
void SetAngle(ETHEntity@ obj, int x, int y){
	if(x == 0){
		if(y == -1)obj.SetAngle(-90.0f);
		if(y == 1)obj.SetAngle(90.0f);
		}
	if(x == 1){
		if(y == -1)obj.SetAngle(-45.0f);
		if(y == 1)obj.SetAngle(45.0f);
		if(y == 0)obj.SetAngle(0.0f);
		}
	if(x == -1){
		if(y == -1)obj.SetAngle(225.0f);
		if(y == 1)obj.SetAngle(135.0f);
		if(y == 0)obj.SetAngle(180.0f);
		}
}

int returnYAngle(float value){
	if(value == -90.0f or value == 90.0f) return 0;
	if(abs(value) == 45.0f or value == 0.0f) return -1;
	if(value == 180.0f or value == 135.0f or value == 225.0f) return 1;
	else{return 2;}
	}
	
int returnXAngle(float value){
	if(value == -90.0f or value == -45.0f or value == 225.0f) return 1;
	if(value == 90.0f or value == 45.0f or value == 135.0f) return -1;
	if(value == 180.0f or value == 0.0f) return 0;
	else{return 2;}
	}