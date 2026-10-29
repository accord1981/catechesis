package repository;

import models.Catequizando;
import java.util.List;

public interface CatequizandoRepository {

    void salvar(Catequizando c);
    void atualizar(Catequizando c);
    void excluir(Long id);
    Catequizando buscarPorId(Long id);
    List<Catequizando> listarTodos();
}
