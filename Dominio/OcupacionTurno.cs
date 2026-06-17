namespace Dominio
{
    // Una celda del reporte de ocupacion: un dia de la semana cruzado con un turno.
    // Es un dato agregado (sale de la vista vw_OcupacionPorTurno), no una Reserva suelta.
    public class OcupacionTurno
    {
        public int DiaNum { get; set; }              // 0=Lunes .. 6=Domingo
        public string Dia { get; set; }
        public int TurnoOrden { get; set; }          // 1=Mañana 2=Tarde 3=Noche
        public string Turno { get; set; }
        public int CantidadReservas { get; set; }    // volumen: cuanta gente hubo
        public decimal PorcentajeOcupacion { get; set; }  // cupos usados sobre ofrecidos
    }
}
