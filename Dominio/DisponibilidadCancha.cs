using System;

namespace Dominio
{
    public class DisponibilidadCancha
    {
        public int IdDisponibilidad { get; set; }
        public DayOfWeek DiaSemana { get; set; }
        public TimeSpan HoraApertura { get; set; }
        public TimeSpan HoraCierre { get; set; }
        public bool Activa { get; set; }
    }
}
