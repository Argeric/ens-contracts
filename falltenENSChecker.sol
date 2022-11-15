// Sources flattened with hardhat v2.9.9 https://hardhat.org

// File contracts/registry/ENS.sol

pragma solidity >=0.8.4;

interface ENS {
    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed node, address owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed node, address resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed node, uint64 ttl);

    // Logged when an operator is added or removed.
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function setRecord(
        bytes32 node,
        address owner,
        address resolver,
        uint64 ttl
    ) external;

    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    ) external;

    function setSubnodeOwner(
        bytes32 node,
        bytes32 label,
        address owner
    ) external returns (bytes32);

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address owner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function setApprovalForAll(address operator, bool approved) external;

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);

    function recordExists(bytes32 node) external view returns (bool);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v4.5.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/utils/introspection/ERC165.sol@v4.5.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// File contracts/resolvers/profiles/IVersionableResolver.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IVersionableResolver {
    event VersionChanged(bytes32 indexed node, uint64 newVersion);

    function recordVersions(bytes32 node) external view returns (uint64);
}


// File contracts/resolvers/ResolverBase.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;


abstract contract ResolverBase is ERC165, IVersionableResolver {
    mapping(bytes32 => uint64) public recordVersions;

    function isAuthorised(bytes32 node) internal view virtual returns (bool);

    modifier authorised(bytes32 node) {
        require(isAuthorised(node));
        _;
    }

    /**
     * Increments the record version associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     */
    function clearRecords(bytes32 node) public virtual authorised(node) {
        recordVersions[node]++;
        emit VersionChanged(node, recordVersions[node]);
    }

    function supportsInterface(bytes4 interfaceID)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceID == type(IVersionableResolver).interfaceId ||
            super.supportsInterface(interfaceID);
    }
}


// File contracts/resolvers/profiles/IABIResolver.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

//import "./IABIResolver.sol";

interface IABIResolver {
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);

    /**
     * Returns the ABI associated with an ENS node.
     * Defined in EIP205.
     * @param node The ENS node to query
     * @param contentTypes A bitwise OR of the ABI formats accepted by the caller.
     * @return contentType The content type of the return value
     * @return data The ABI data
     */
    function ABI(bytes32 node, uint256 contentTypes)
        external
        view
        returns (uint256, bytes memory);
}


// File contracts/resolvers/profiles/IAddressResolver.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/**
 * Interface for the new (multicoin) addr function.
 */
interface IAddressResolver {
    event AddressChanged(
        bytes32 indexed node,
        uint256 coinType,
        bytes newAddress
    );

    function addr(bytes32 node, uint256 coinType)
        external
        view
        returns (bytes memory);
}


// File contracts/resolvers/profiles/IAddrResolver.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

/**
 * Interface for the legacy (ETH-only) addr function.
 */
interface IAddrResolver {
    event AddrChanged(bytes32 indexed node, address a);

    /**
     * Returns the address associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) external view returns (address payable);
}


// File contracts/resolvers/profiles/IContentHashResolver.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IContentHashResolver {
    event ContenthashChanged(bytes32 indexed node, bytes hash);

    /**
     * Returns the contenthash associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated contenthash.
     */
    function contenthash(bytes32 node) external view returns (bytes memory);
}


// File contracts/resolvers/profiles/IDNSRecordResolver.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IDNSRecordResolver {
    // DNSRecordChanged is emitted whenever a given node/name/resource's RRSET is updated.
    event DNSRecordChanged(
        bytes32 indexed node,
        bytes name,
        uint16 resource,
        bytes record
    );
    // DNSRecordDeleted is emitted whenever a given node/name/resource's RRSET is deleted.
    event DNSRecordDeleted(bytes32 indexed node, bytes name, uint16 resource);

    /**
     * Obtain a DNS record.
     * @param node the namehash of the node for which to fetch the record
     * @param name the keccak-256 hash of the fully-qualified name for which to fetch the record
     * @param resource the ID of the resource as per https://en.wikipedia.org/wiki/List_of_DNS_record_types
     * @return the DNS record in wire format if present, otherwise empty
     */
    function dnsRecord(
        bytes32 node,
        bytes32 name,
        uint16 resource
    ) external view returns (bytes memory);
}


// File contracts/resolvers/profiles/IDNSZoneResolver.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IDNSZoneResolver {
    // DNSZonehashChanged is emitted whenever a given node's zone hash is updated.
    event DNSZonehashChanged(
        bytes32 indexed node,
        bytes lastzonehash,
        bytes zonehash
    );

    /**
     * zonehash obtains the hash for the zone.
     * @param node The ENS node to query.
     * @return The associated contenthash.
     */
    function zonehash(bytes32 node) external view returns (bytes memory);
}


// File contracts/resolvers/profiles/IInterfaceResolver.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IInterfaceResolver {
    event InterfaceChanged(
        bytes32 indexed node,
        bytes4 indexed interfaceID,
        address implementer
    );

    /**
     * Returns the address of a contract that implements the specified interface for this name.
     * If an implementer has not been set for this interfaceID and name, the resolver will query
     * the contract at `addr()`. If `addr()` is set, a contract exists at that address, and that
     * contract implements EIP165 and returns `true` for the specified interfaceID, its address
     * will be returned.
     * @param node The ENS node to query.
     * @param interfaceID The EIP 165 interface ID to check for.
     * @return The address that implements this interface, or 0 if the interface is unsupported.
     */
    function interfaceImplementer(bytes32 node, bytes4 interfaceID)
        external
        view
        returns (address);
}


// File contracts/resolvers/profiles/INameResolver.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface INameResolver {
    event NameChanged(bytes32 indexed node, string name);

    /**
     * Returns the name associated with an ENS node, for reverse records.
     * Defined in EIP181.
     * @param node The ENS node to query.
     * @return The associated name.
     */
    function name(bytes32 node) external view returns (string memory);
}


// File contracts/resolvers/profiles/IPubkeyResolver.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IPubkeyResolver {
    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);

    /**
     * Returns the SECP256k1 public key associated with an ENS node.
     * Defined in EIP 619.
     * @param node The ENS node to query
     * @return x The X coordinate of the curve point for the public key.
     * @return y The Y coordinate of the curve point for the public key.
     */
    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y);
}


// File contracts/resolvers/profiles/ITextResolver.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface ITextResolver {
    event TextChanged(
        bytes32 indexed node,
        string indexed indexedKey,
        string key,
        string value
    );

    /**
     * Returns the text data associated with an ENS node and key.
     * @param node The ENS node to query.
     * @param key The text data key to query.
     * @return The associated text data.
     */
    function text(bytes32 node, string calldata key)
        external
        view
        returns (string memory);
}


// File contracts/resolvers/profiles/IExtendedResolver.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IExtendedResolver {
    function resolve(bytes memory name, bytes memory data)
        external
        view
        returns (bytes memory, address);
}


// File contracts/resolvers/Resolver.sol

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;












/**
 * A generic resolver interface which includes all the functions including the ones deprecated
 */
interface Resolver is
    IERC165,
    IABIResolver,
    IAddressResolver,
    IAddrResolver,
    IContentHashResolver,
    IDNSRecordResolver,
    IDNSZoneResolver,
    IInterfaceResolver,
    INameResolver,
    IPubkeyResolver,
    ITextResolver,
    IExtendedResolver
{
    /* Deprecated events */
    event ContentChanged(bytes32 indexed node, bytes32 hash);

    function setABI(
        bytes32 node,
        uint256 contentType,
        bytes calldata data
    ) external;

    function setAddr(bytes32 node, address addr) external;

    function setAddr(
        bytes32 node,
        uint256 coinType,
        bytes calldata a
    ) external;

    function setContenthash(bytes32 node, bytes calldata hash) external;

    function setDnsrr(bytes32 node, bytes calldata data) external;

    function setName(bytes32 node, string calldata _name) external;

    function setPubkey(
        bytes32 node,
        bytes32 x,
        bytes32 y
    ) external;

    function setText(
        bytes32 node,
        string calldata key,
        string calldata value
    ) external;

    function setInterface(
        bytes32 node,
        bytes4 interfaceID,
        address implementer
    ) external;

    function multicall(bytes[] calldata data)
        external
        returns (bytes[] memory results);

    function multicallWithNodeCheck(bytes32 nodehash, bytes[] calldata data)
        external
        returns (bytes[] memory results);

    /* Deprecated functions */
    function content(bytes32 node) external view returns (bytes32);

    function multihash(bytes32 node) external view returns (bytes memory);

    function setContent(bytes32 node, bytes32 hash) external;

    function setMultihash(bytes32 node, bytes calldata hash) external;
}


// File contracts/registry/IReverseRegistrar.sol

pragma solidity >=0.8.4;

interface IReverseRegistrar {
    function setDefaultResolver(address resolver) external;

    function claim(address owner) external returns (bytes32);

    function claimForAddr(
        address addr,
        address owner,
        address resolver
    ) external returns (bytes32);

    function claimWithResolver(address owner, address resolver)
        external
        returns (bytes32);

    function setName(string memory name) external returns (bytes32);

    function setNameForAddr(
        address addr,
        address owner,
        address resolver,
        string memory name
    ) external returns (bytes32);

    function node(address addr) external pure returns (bytes32);
}


// File contracts/utils/ENSNamehash.sol

pragma solidity ^0.8.4;

/*
 * @dev Solidity implementation of the ENS namehash algorithm.
 * Warning! Does not normalize or validate names before hashing.
 */

// put this file under  https://github.com/ensdomains/ens-contracts.git/contracts/utils
// then compile and get abi
library ENSNamehash {

    function namehash(bytes memory domain)
    internal pure
    returns (bytes32)
    {
        return namehash(domain, 0);
    }

    function namehash(bytes memory domain, uint i)
    internal pure
    returns (bytes32)
    {
        if (domain.length <= i)
            return 0x0000000000000000000000000000000000000000000000000000000000000000;

        uint len = LabelLength(domain, i);

        return keccak256(abi.encodePacked(namehash(domain, i+len+1), keccak(domain, i, len)));
    }

    function LabelLength(bytes memory domain, uint i)
    private pure
    returns (uint)
    {
        uint len;
        while (i+len != domain.length && domain[i+len] != 0x2e) {
            len++;
        }
        return len;
    }

    function keccak(bytes memory data, uint offset, uint len)
    private pure
    returns (bytes32 ret)
    {
        require(offset + len <= data.length);
        assembly {
            ret := keccak256(add(add(data, 32), offset), len)
        }
    }
}


// File contracts/utils/ENSChecker.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;




// put this file under  https://github.com/ensdomains/ens-contracts.git/contracts/utils
// then compile and get abi
contract ENSChecker {

    using ENSNamehash for bytes;

    function getReverseNameByAddress(address ens,address reverse, address who)
    public view
    returns (string memory)
    {
        bytes32 node = IReverseRegistrar(reverse).node(who);
        address resolver = ENS(ens).resolver(node);
        if (resolver == address(0)) {
            return '';
        }
        return Resolver(resolver).name(node);
    }

    function getAddrOfName(address ens,address reverse, string memory name)
    public view
    returns (address resolvedAddr,bytes32 node)
    {
        bytes32 node = (bytes(name)).namehash();
        address resolver = ENS(ens).resolver(node);
        if (resolver == address(0)) {
            return (address(0),node);
        }
        address resolvedAddr = Resolver(resolver).addr(node);
        return (resolvedAddr, node);
    }

    function getEnsNameMatch(address ens,address reverse, address who, string memory domain)
    public view
    returns (string memory)
    {
        string memory name = getReverseNameByAddress(ens, reverse, who);
        if(bytes(domain).length > 0) {
            name = string(abi.encodePacked(name, domain));
        }
        bytes32 node;
        address resolvedAddr;
        (resolvedAddr, node) = getAddrOfName(ens, reverse, name);
        if (resolvedAddr == who) {
            return name;
        }
        return '';
    }

    function matchNames(address ens,address reverse, address[] memory addrArr, string memory domain)
    public view
    returns (string[] memory)
    {
        string[] memory ret = new string[](addrArr.length);
        for(uint256 i=0; i<addrArr.length; i++) {
            ret[i] = getEnsNameMatch(ens, reverse, addrArr[i], domain);
        }
        return ret;
    }
}
