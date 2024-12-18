#include <GL/gl.h>
#include <GL/glu.h>
#include <GLFW/glfw3.h>
#include <math.h>
#include <stdio.h>

#define PI 3.14159265359

void process_input_c(GLFWwindow* window) {
    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GLFW_TRUE);
    }
}


void framebuffer_size_callback_c(GLFWwindow* surface, int width, int height) {
    glViewport(0, 0, width, height);
}

void drawCircle(double radio, double posx, double posy, int vertexs, double pitch) {

    double sums = 2 * PI / vertexs;

    glBegin(GL_LINE_LOOP);
    for(float angle = 0; angle < 2 * PI; angle = angle + sums) {
        float x = radio * cos(angle + pitch);
        float y = radio * sin(angle + pitch);

        glVertex2d(x + posx, y + posy);
    }
    glEnd();
}

void drawSphere(float radio, float posx, float posy, float posz, int segments) {
    float thetaStep = PI / segments;   // Incremento para la latitud
    float phiStep = 2 * PI / segments; // Incremento para la longitud

    for(float theta = 0; theta <= 2 * PI; theta += thetaStep) {
        glBegin(GL_TRIANGLE_STRIP);
        // glBegin(GL_POINTS);

        for(float phi = 0; phi <= 2 * PI; phi += phiStep) {
            // Primer vértice de la tira
            float x1 = radio * sin(theta) * cos(phi) + posx;
            float y1 = radio * sin(theta) * sin(phi) + posy;
            float z1 = radio * cos(theta) + posz;

            glVertex3d(x1, y1, z1);

            // Segundo vértice de la tira
            float x2 = radio * sin(theta + thetaStep) * cos(phi) + posx;
            float y2 = radio * sin(theta + thetaStep) * sin(phi) + posy;
            float z2 = radio * cos(theta + thetaStep) + posz;

            glVertex3f(x2, y2, z2);
        }

        glEnd();
    }
}


void setCamera(double cameraX, double cameraY, double cameraZ, double targetX, double targetY, double targetZ) {
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(targetX, targetY, targetZ, // Punto de enfoque
    cameraX, cameraY, cameraZ,           // Posición de la cámara
    0.0f, 0.0f, 1.0f);
    // upX, upY, upZ                        // Vector "up"
}

void rotateCamera(float angle, float axisX, float axisY, float axisZ) {
    // Rota la cámara alrededor del punto de enfoque
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glRotatef(angle, axisX, axisY, axisZ);
}

void drawLine(float x1, float y1, float z1, float x2, float y2, float z2) {
    glBegin(GL_LINES);

    glVertex3f(x1, y1, z1);
    glVertex3f(x2, y2, z2);

    glEnd();
}
