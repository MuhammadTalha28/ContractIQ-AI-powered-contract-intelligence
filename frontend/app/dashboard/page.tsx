'use client'

import { useState, useEffect } from 'react'
import axios from 'axios'
import Link from 'next/link'

interface Contract {
  id: string
  filename: string
  uploadedAt: string
  status: 'processing' | 'completed' | 'failed'
  riskScore?: number
  clausesCount?: number
  summary?: string
}

export default function DashboardPage() {
  const [contracts, setContracts] = useState<Contract[]>([])
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    fetchContracts()
  }, [])

  const fetchContracts = async () => {
    try {
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'https://YOUR_API_GATEWAY_URL/dev'
      const response = await axios.get(`${apiUrl}/contracts`)
      setContracts(response.data)
    } catch (error) {
      console.error('Failed to fetch contracts:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const getRiskColor = (score?: number) => {
    if (!score) return 'bg-gray-500'
    if (score >= 70) return 'bg-red-500'
    if (score >= 40) return 'bg-yellow-500'
    return 'bg-green-500'
  }

  const getRiskLabel = (score?: number) => {
    if (!score) return 'N/A'
    if (score >= 70) return 'High Risk'
    if (score >= 40) return 'Medium Risk'
    return 'Low Risk'
  }

  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4">
      <div className="max-w-7xl mx-auto">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Contract Dashboard</h1>
          <Link
            href="/upload"
            className="bg-primary-600 text-white px-6 py-3 rounded-lg hover:bg-primary-700 transition"
          >
            Upload New Contract
          </Link>
        </div>

        {isLoading ? (
          <div className="text-center py-12">
            <p className="text-gray-600">Loading contracts...</p>
          </div>
        ) : contracts.length === 0 ? (
          <div className="bg-white rounded-lg shadow-lg p-12 text-center">
            <p className="text-gray-600 mb-4">No contracts uploaded yet.</p>
            <Link
              href="/upload"
              className="inline-block bg-primary-600 text-white px-6 py-3 rounded-lg hover:bg-primary-700 transition"
            >
              Upload Your First Contract
            </Link>
          </div>
        ) : (
          <div className="grid gap-6">
            {contracts.map((contract) => (
              <div
                key={contract.id}
                className="bg-white rounded-lg shadow-lg p-6 hover:shadow-xl transition"
              >
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h2 className="text-xl font-semibold text-gray-900 mb-2">
                      {contract.filename}
                    </h2>
                    <p className="text-sm text-gray-500">
                      Uploaded: {new Date(contract.uploadedAt).toLocaleString()}
                    </p>
                  </div>
                  <div className="flex items-center gap-4">
                    {contract.riskScore !== undefined && (
                      <div className="text-right">
                        <div
                          className={`inline-block px-4 py-2 rounded-full text-white font-semibold ${getRiskColor(
                            contract.riskScore
                          )}`}
                        >
                          {getRiskLabel(contract.riskScore)} ({contract.riskScore}/100)
                        </div>
                      </div>
                    )}
                    <span
                      className={`px-3 py-1 rounded-full text-sm font-medium ${
                        contract.status === 'completed'
                          ? 'bg-green-100 text-green-800'
                          : contract.status === 'processing'
                          ? 'bg-yellow-100 text-yellow-800'
                          : 'bg-red-100 text-red-800'
                      }`}
                    >
                      {contract.status}
                    </span>
                  </div>
                </div>

                {(contract.status === 'completed' || contract.status === 'analyzed') && (
                  <div className="mt-4 pt-4 border-t border-gray-200">
                    <div className="grid md:grid-cols-2 gap-4">
                      <div>
                        <p className="text-sm text-gray-600 mb-1">Clauses Extracted</p>
                        <p className="text-lg font-semibold text-gray-900">
                          {contract.clausesCount || 0}
                        </p>
                      </div>
                      {contract.summary && (
                        <div>
                          <p className="text-sm text-gray-600 mb-1">Summary</p>
                          <p className="text-sm text-gray-800 line-clamp-2">
                            {contract.summary}
                          </p>
                        </div>
                      )}
                    </div>
                    <div className="mt-4">
                      <Link
                        href={`/contracts/${contract.id}`}
                        className="text-primary-600 hover:text-primary-700 font-medium"
                      >
                        View Full Analysis →
                      </Link>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

