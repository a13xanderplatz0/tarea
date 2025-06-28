#include <iostream>
#include <algorithm>
using namespace std;

// Functor para orden ascendente
struct ascendente {
    bool operator()(const int& a, const int& b) const {
        return a < b;
    }
};

// Functor para orden descendente
struct descendente {
    bool operator()(const int& a, const int& b) const {
        return a > b;
    }
};

template <class T, class O>
class ordena {
public:
    void ordenar(T* inicio, T* fin) {
        O orden;
        std::sort(inicio, fin, orden);/*hibrido(introsort) la stl decide internamente*/
        cout << "Arreglo ordenado: ";
        for (T* it = inicio; it != fin; ++it) {
            cout << *it << " ";
        }
        cout << endl;
    }
};

int main() {
    int arr[] = {9, 3, 13, 1, 5, 6};
    int n = 6;

    // Ascendente
    ordena<int, ascendente> ordenASC;
    ordenASC.ordenar(arr, arr + n);

    // Descendente (hacemos una copia manual)
    int arr2[] = {9, 3, 13, 1, 5, 6};
    ordena<int, descendente> ordenDESC;
    ordenDESC.ordenar(arr2, arr2 + n);

    return 0;
}
