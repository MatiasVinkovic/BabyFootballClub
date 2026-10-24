#pragma once

#include <string>
#include <vector>

#include "core/Regle.hpp"

namespace babyfoot::core {

    // interface pour le repository de regles, qui définit les opérations de base pour gérer les regles
    // Quiconque prétend stocker ou récupérer des règles doit savoir faire ces 3 actions
class IRegleRepository {
    public: 
        //destructeur par défaut
        virtual ~IRegleRepository() = default;
        virtual void init() = 0;
        virtual std::vector<Regle> getAll() = 0;
        virtual Regle add(const std::string& titre, const std::string& contenu) = 0;
};

// logique métier pour gérer les règles, qui utilise un repository pour stocker et récupérer les règles
class RegleService {
    private:
        IRegleRepository& repository_;

    public:
        explicit RegleService(IRegleRepository& repository)
            : repository_{repository} {}

        void initialize() {
            repository_.init();
        }

        std::vector<Regle> regles()  {
            return repository_.getAll();
        }

        Regle addRegle(const std::string& titre, const std::string& contenu) {
            return repository_.add(titre, contenu);
        };
};

}