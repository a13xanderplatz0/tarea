#include <iostream>
#include <algorithm> // Incluido por la implementación original, aunque no se usa en el código descomentado.

// --- Clase Iterador Simple ---
// Abstrae el puntero para trabajar con rangos de datos de forma genérica.
template <typename T>
class Iterador {
private:
    T* puntero; // Puntero al elemento actual.

public:
    // Constructor.
    Iterador(T* p) : puntero(p) {}

    // Operador de desreferencia: Permite acceder al valor del elemento.
    T& operator*() const {
        return *puntero;
    }

    // Operador de incremento (prefijo): Mueve el iterador al siguiente elemento.
    Iterador& operator++() {
        ++puntero;
        return *this;
    }

    // Operador de comparación: Compara si dos iteradores no son iguales.
    bool operator!=(const Iterador& otro) const {
        return puntero != otro.puntero;
    }

    // --- Funcionalidad adicional para la lógica del Bubble Sort ---
    // Este operador permite crear un nuevo iterador que apunta al siguiente elemento.
    // Es útil para la comparación de elementos adyacentes.
    Iterador operator+(int n) const {
        return Iterador(puntero + n);
    }
};

// --- Clases de Comparadores (Functors) ---
// Actúan como funciones para definir el orden de clasificación.

// Para ordenar de forma ascendente.
class ascendente {
public:
    bool operator()(const int& a, const int& b) const {
        return a < b;
    }
};

// Para ordenar de forma descendente.
class descendente {
public:
    bool operator()(const int& a, const int& b) const {
        return a > b;
    }
};

---

### Clase de Ordenamiento (`ordena`)

// Esta clase template usa un tipo de dato (T) y un operador de orden (O).
template <class T, class O>
class ordena {
public:
    // **Función 'ordenar' modificada para usar la clase 'Iterador'.**
    void ordenar(Iterador<T> inicio, Iterador<T> fin) {
        O orden; // Crea una instancia del comparador.

        // Usa el algoritmo de ordenamiento de burbuja (Bubble Sort).
        // Los bucles ahora operan directamente sobre los objetos Iterador.
        for (Iterador<T> i = inicio; i != fin; ++i) {
            for (Iterador<T> j = inicio; j != fin + -1; ++j) {
                // Se usa el operador de desreferencia (*) y el nuevo operador (+) del iterador.
                if (orden(*j, *(j + 1))) {
                    // Intercambia los valores.
                    T tmp = *j;
                    *j = *(j + 1);
                    *(j + 1) = tmp;
                }
            }
        }

        // Muestra el arreglo ordenado usando iteradores.
        std::cout << "Arreglo ordenado: ";
        for (Iterador<T> it = inicio; it != fin; ++it) {
            std::cout << *it << " ";
        }
        std::cout << std::endl;
    }
};

---

### Función Principal (`main`)

int main() {
    int arr[] = {9, 3, 13, 1, 5, 6};
    int n = 6;

    // --- Ordenamiento Ascendente ---
    // Se crean instancias del iterador para definir el rango.
    Iterador<int> inicioAsc(arr);
    Iterador<int> finAsc(arr + n);
    ordena<int, ascendente> ordenASC;
    ordenASC.ordenar(inicioAsc, finAsc);

    // --- Ordenamiento Descendente ---
    // Se usa una copia del arreglo para el segundo ordenamiento.
    int arr2[] = {9, 3, 13, 1, 5, 6};
    Iterador<int> inicioDesc(arr2);
    Iterador<int> finDesc(arr2 + n);
    ordena<int, descendente> ordenDESC;
    ordenDESC.ordenar(inicioDesc, finDesc);

    return 0;
}
