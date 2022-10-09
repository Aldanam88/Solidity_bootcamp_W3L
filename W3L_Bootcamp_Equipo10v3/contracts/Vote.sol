// "SPDX-License-Identifier: MIT"
pragma solidity ^0.8.0;

// Contrato de Open Zeppelin que nos permite pausar el contrato cuando termine la votacion 
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";

contract Vote is Pausable{

    struct leyes {
        uint8 id;
        string descripcion;
        uint256 votos;
    }

    struct Votantes {
        bool votoRegistrado;
        bool puedeVotar;
    }
    
    mapping (address => Votantes) public votantes;

    leyes public l1; 
    leyes public l2;

    address public owner;

    uint8 public votosDiputados;
    uint8 public votosSenadores;
    uint8 public VotosNoValidos;



    // Se registran las leyes a votar en el constructor 
    constructor(string memory _descripcion, uint8 _id1, string memory _descripcion2, uint8 _id2){
        
        owner = msg.sender;
        l1.descripcion = _descripcion;
        l1.id = _id1;

        l2.descripcion = _descripcion2;
        l2.id = _id2;
    }

    // Asignar a alguien el derecho a votar validando el owner 
    function derechoAVotar(address votante) public whenNotPaused{
        require(owner == msg.sender, "Solo el owner puede dar derecho a voto");
        votantes[votante].puedeVotar = true;
    }
    
    // Votar:
         // aumentar el numero de votos por tu candidato seleccionado 
    // Validaciones:   
         // Valida que el contrato no este pausado y que la votacion sigue abierta 
         // valida que el usuario tenga asignado el derecho a votar  
         // valida que el usuario vote una sola vez
         // valida que el usuario indique si es Diputado o Senador  
         // valida que solo puedan votar 72 senadores y 257 diputados. Para fines de la demo se limita a 1 senador y 2 diputados
    function votar(uint8 idLey, string memory tipoVotante )public whenNotPaused{
         
        require(votantes[msg.sender].puedeVotar, "No tienes derecho a votar");
        
        require(votantes[msg.sender].votoRegistrado == false, "Ya tiene un voto registrado");

        require(keccak256(bytes(tipoVotante)) == keccak256(bytes("Diputado")) || keccak256(bytes(tipoVotante)) == keccak256(bytes("Senador")), "Debe ser Diputado o Senador para registrar su voto");
                
       
        if (keccak256(bytes(tipoVotante)) == keccak256(bytes("Diputado"))){
            require(votosDiputados < 2 , "Ya se han registrado todos los votos de diputados"); 
            votosDiputados += 1;
        } if (keccak256(bytes(tipoVotante)) == keccak256(bytes("Senador"))){
            require(votosSenadores < 1  , "Ya se han registrado todos los votos de senadores"); 
            votosSenadores +=1; 
        }

        //Registra el voto una vez que pasa las validaciones
        votantes[msg.sender].votoRegistrado = true; 

        //Asigna el voto a la ley correspondiente o votos en blanco/anulados  
        if(idLey == l1.id ){
            l1.votos += 1;            
        } else if(idLey == l2.id ) {
            l2.votos += 1;
        } else{
            VotosNoValidos += 1;
        }
         
    }
 
    // PAUSAR EL CONTRATO 
     function pause() public whenNotPaused {
        require(owner == msg.sender, "Solo el owner puede pausar el contrato");
        require(votosDiputados == 2 , "No se han registrado todos los votos de diputados");
        require(votosSenadores == 1 , "No se han registrado todos los votos de senadores");

        _pause();
    }

    // REANUDAR EL CONTRATO 
     function unpause() public whenPaused {
        require(owner == msg.sender, "Solo el owner puede reanudar el contrato");
        _unpause();
    }
   

   //Una vez finalizada la votación se debe poder ver al ganador 
   //Se muestra la dirección del contrato inteligente.

   function candidatxGanador() public view whenPaused returns(uint8, address) {
       uint8 idganador; 
       if(l1.votos > l2.votos){
           idganador = l1.id;
        } if(l1.votos < l2.votos){
           idganador = l2.id;
        }
        address contrato = address(this);
        return (idganador,contrato );
   }
}