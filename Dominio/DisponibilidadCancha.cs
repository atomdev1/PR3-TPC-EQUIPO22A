using System;
using Dominio.Enums;

namespace Dominio
{
    public class DisponibilidadCancha
    {
        public int IdDisponibilidad { get; set; }
        public DiaSemana DiaSemana { get; set; }
        public TimeSpan HoraApertura { get; set; }
        public TimeSpan HoraCierre { get; set; }
        public bool Activa { get; set; }
    }
}
