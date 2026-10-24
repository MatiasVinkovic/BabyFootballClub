#pragma once

#include <string>
#include <vector>
#include <QString>

#include "core/Regle.hpp"
#include "core/RegleService.hpp" 

namespace babyfoot::infra {

class SqliteRegleRepository final : public babyfoot::core::IRegleRepository {
public:
    explicit SqliteRegleRepository(QString databasePath);

    void init() override;
    std::vector<babyfoot::core::Regle> getAll() override;
    babyfoot::core::Regle add(const std::string& titre, const std::string& contenu) override;

private:
    QString databasePath_;
};

}