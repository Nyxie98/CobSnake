#include <raylib.h>
#include <stdlib.h>
#include <time.h>

#define MAX_TEXTURES 99
#define MAX_SOUNDS 99
#define MAX_RECTANGLES 99

#define RL_TRUE 1
#define RL_FALSE 0

static Texture2D textures[MAX_TEXTURES];
static int currentTextureCount = 0;

static Sound sounds[MAX_SOUNDS];
static int currentSoundCount = 0;

static Rectangle rectangles[MAX_RECTANGLES];
static int currentRectangleCount = 0;

// wrapper functions
void b_ClearBackground(int r, int g, int b, int a)
{
    ClearBackground((Color){ r, g, b});
}
void b_DrawText(
    const char* text,
    int x, int y, int size,
    int r, int g, int b, int a)
{
    DrawText(text, x, y, size, (Color){ r, g, b, a });
}
int b_LoadTexture(const char* path)
{
    textures[currentTextureCount] = LoadTexture(path);

    return currentTextureCount++;
}
void b_DrawTexture(
    unsigned int texture,
    int x, int y,
    int r, int g, int b, int a)
{
    DrawTexture(textures[texture], x, y, (Color){ r, g, b, a});
}
void b_UnloadTexture(unsigned int texture)
{
    UnloadTexture(textures[texture]);
}
int b_IsKeyDown(int key)
{
    return IsKeyDown(key) ? RL_TRUE : RL_FALSE;
}
int b_IsKeyPressed(int key)
{
    return IsKeyPressed(key) ? RL_TRUE : RL_FALSE;
}
void b_SetTextureSize(unsigned int texture, unsigned int width, unsigned int height)
{
    textures[texture].width = width;
    textures[texture].height = height;
}
int b_LoadSound(const char* path)
{
    sounds[currentSoundCount] = LoadSound(path);

    return currentSoundCount++;
}
void b_UnloadSound(unsigned int sound)
{
    UnloadSound(sounds[sound]);
}
void b_PlaySound(unsigned int sound)
{
    PlaySound(sounds[sound]);
}
int b_IsMouseButtonPressed(int button)
{
    return IsMouseButtonPressed(button) ? RL_TRUE : RL_FALSE;
}
int b_IsMouseButtonDown(int button)
{
    return IsMouseButtonDown(button) ? RL_TRUE : RL_FALSE;
}
void b_DrawRectangle(
    int x, int y,
    int width, int height,
    int r, int g, int b, int a)
{
    DrawRectangle(x, y, width, height, (Color){r, g, b, a});
}

// random functions, they are definitely better than COBOL's ones

void b_InitRandom()
{
    srand(time(0));
}
int b_RandomRange(int low, int high)
{
    return rand() % (high - low) + low;
}
unsigned int b_CreateRectangle()
{
    return currentRectangleCount++;
}
void b_RectangleSetX(unsigned int rectangle, int x)
{
    rectangles[rectangle].x = x;
}
void b_RectangleSetY(unsigned int rectangle, int y)
{
    rectangles[rectangle].y = y;
}
void b_RectangleSetWidth(unsigned int rectangle, unsigned int width)
{
    rectangles[rectangle].width = width;
}
void b_RectangleSetHeight(unsigned int rectangle, unsigned int height)
{
    rectangles[rectangle].height = height;
}
int b_CheckCollisionRecs(unsigned int rec1, unsigned int rec2)
{
    return CheckCollisionRecs(rectangles[rec1], rectangles[rec2]) ? RL_TRUE : RL_FALSE;
}