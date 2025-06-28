#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

template <class T, class O>
class ordena {
public:
    typename std::vector<T>::iterator recorre;

    /*me permite elegir el criterio de ordenamiento */
    ordena() {}

    void ordenar(std::vector<T>& vec) {
        O orden;
        std::sort(vec.begin(), vec.end(), orden);
        cout << "Vector ordenado: ";
        for (recorre = vec.begin(); recorre != vec.end(); ++recorre) {
            cout << *recorre << " ";
        }
        cout << endl;
    }
};

struct ascendente {
    bool operator()(const int& a, const int& b) const {
        return a < b;
    }
};

struct descendente {
    bool operator()(const int& a, const int& b) const {
        return a > b;
    }
};

int main() {
    std::vector<int> vec = {9, 3, 13, 1, 5, 6};

    // Ascendente
    ordena<int, ascendente> ordenASC;
    ordenASC.ordenar(vec);

    // Descendente (hacemos una copia para no perder el orden ascendente)
    std::vector<int> vec2 = vec;
    ordena<int, descendente> ordenDESC;
    ordenDESC.ordenar(vec2);

    /*uso dos variables(vec ,vec2) para copiar el vector original */
    return 0;
}
