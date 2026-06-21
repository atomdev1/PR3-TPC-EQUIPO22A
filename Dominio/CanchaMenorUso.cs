using System;

namespace Dominio
{
    // Mapea una fila de la vista vw_CanchasMenorUso.
    // No reusa Cancha porque la vista trae columnas propias (ReservasXMes, Mes, Anio)
    public class CanchaMenorUso
    {
        public int IdCancha { get; set; }
        public int NroCancha { get; set; }
        public string NombreFantasia { get; set; }
        public string Deporte { get; set; }
        public int ReservasXMes { get; set; }
        public int Mes { get; set; }
        public int Anio { get; set; }
    }
}