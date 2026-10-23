#pragma once

#include <string>
#include <vector>

#include "core/Regle.hpp"

namespace babyfoot::core {

class IRegleRepository {
public: 
    //destructeur par défaut
    virtual ~IRegleRepository() = default;
    virtual void init() = 0;
    virtual std::vector<Regle> getAll = 0;
    virtual Regle add(const std::string& nom, const std::string& contenu) = 0;
}

class RegleService {
private:
    IRegleRepository& repository_;
};

public:
    explicit RegleService(IRegleRepository& repository)
        : repository_{repository} {}

    void initialize() {
        repository_.init();
    }

    std::vector<Regle> regles()  {
        return repository_.getAll();
    }

    Player addRegle(const std::string& nom, const std::string& contenu) {
        return repository_.add(nom, contenu);
    }
}